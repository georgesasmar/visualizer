import 'dart:async';
import 'package:flutter/material.dart';

import '../models/spotify_models.dart';
import '../models/visualizer_models.dart';
import '../services/spotify_service.dart';
import '../services/visualizer_service.dart';
import '../services/widget_service.dart';
import '../theme/app_theme.dart';

enum AppStatus { loading, unauthenticated, authenticated }

class AppStateProvider with ChangeNotifier {
  final SpotifyService _spotifyService;
  final VisualizerService _visualizerService;
  final WidgetService _widgetService;

  AppStateProvider({
    required SpotifyService spotifyService,
    required VisualizerService visualizerService,
    required WidgetService widgetService,
  }) : _spotifyService = spotifyService,
       _visualizerService = visualizerService,
       _widgetService = widgetService {
    _initialize();
  }

  // App state
  AppStatus _appStatus = AppStatus.loading;
  ThemeMode _themeMode = ThemeMode.system;

  // Spotify state
  CurrentlyPlaying? _currentlyPlaying;
  AudioAnalysis? _currentAudioAnalysis;
  AudioFeatures? _currentAudioFeatures;

  // Visualizer state
  VisualizerData _visualizerData = VisualizerData(
    amplitudes: List.filled(200, 0.5),
    currentProgress: 0.0,
    style: VisualizerStyle.oscilloscope,
    primaryColor: AppTheme.neonGreen,
  );

  Timer? _updateTimer;
  String? _lastTrackId;

  // Getters
  AppStatus get appStatus => _appStatus;
  ThemeMode get themeMode => _themeMode;
  CurrentlyPlaying? get currentlyPlaying => _currentlyPlaying;
  VisualizerData get visualizerData => _visualizerData;
  bool get isPlaying => _currentlyPlaying?.isPlaying ?? false;
  double get trackProgress {
    if (_currentlyPlaying?.progressMs == null || 
        _currentlyPlaying?.item?.durationMs == null) return 0.0;
    return _currentlyPlaying!.progressMs! / _currentlyPlaying!.item!.durationMs;
  }

  Future<void> _initialize() async {
    try {
      await _spotifyService.initialize();
      await _widgetService.initialize();
      
      if (_spotifyService.isAuthenticated) {
        _appStatus = AppStatus.authenticated;
        _startPeriodicUpdates();
      } else {
        _appStatus = AppStatus.unauthenticated;
      }
    } catch (e) {
      print('Initialization error: $e');
      _appStatus = AppStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> authenticate() async {
    final success = await _spotifyService.authenticate();
    if (success) {
      _appStatus = AppStatus.authenticated;
      _startPeriodicUpdates();
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    _updateTimer?.cancel();
    await _spotifyService.logout();
    await _widgetService.cancelAllUpdates();
    _appStatus = AppStatus.unauthenticated;
    _currentlyPlaying = null;
    _resetVisualizerData();
    notifyListeners();
  }

  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateCurrentlyPlaying();
    });
    
    // Schedule widget updates
    _widgetService.schedulePeriodicUpdates();
  }

  Future<void> _updateCurrentlyPlaying() async {
    try {
      final currentlyPlaying = await _spotifyService.getCurrentlyPlaying();
      
      if (currentlyPlaying != null) {
        _currentlyPlaying = currentlyPlaying;
        
        // Check if track changed
        final trackId = currentlyPlaying.item?.id;
        if (trackId != null && trackId != _lastTrackId) {
          _lastTrackId = trackId;
          await _loadTrackAnalysis(trackId);
        }
        
        // Update visualizer progress
        _updateVisualizerProgress();
        
        // Update widget
        _updateWidget();
      } else {
        _currentlyPlaying = null;
        _resetVisualizerData();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating currently playing: $e');
    }
  }

  Future<void> _loadTrackAnalysis(String trackId) async {
    try {
      final results = await Future.wait([
        _spotifyService.getAudioAnalysis(trackId),
        _spotifyService.getAudioFeatures(trackId),
      ]);

      final analysis = results[0] as AudioAnalysis?;
      final features = results[1] as AudioFeatures?;

      if (analysis != null && features != null) {
        _currentAudioAnalysis = analysis;
        _currentAudioFeatures = features;
        
        // Generate waveform
        final waveform = _visualizerService.generateSimplifiedWaveform(
          analysis,
          features,
          sampleCount: _visualizerData.sampleRate,
        );
        
        _visualizerData = _visualizerData.copyWith(amplitudes: waveform);
      }
    } catch (e) {
      print('Error loading track analysis: $e');
    }
  }

  void _updateVisualizerProgress() {
    if (_currentlyPlaying?.progressMs != null && 
        _currentlyPlaying?.item?.durationMs != null) {
      final progress = _currentlyPlaying!.progressMs! / 
                      _currentlyPlaying!.item!.durationMs;
      _visualizerData = _visualizerData.copyWith(
        currentProgress: progress,
        isPlaying: _currentlyPlaying!.isPlaying,
      );
    }
  }

  void _updateWidget() {
    _widgetService.updateWidget(
      currentTrack: _currentlyPlaying,
      visualizerData: _visualizerData,
    );
  }

  void _resetVisualizerData() {
    _visualizerData = VisualizerData(
      amplitudes: List.filled(_visualizerData.sampleRate, 0.5),
      currentProgress: 0.0,
      isPlaying: false,
      style: _visualizerData.style,
      primaryColor: _visualizerData.primaryColor,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setVisualizerStyle(VisualizerStyle style) {
    _visualizerData = _visualizerData.copyWith(style: style);
    notifyListeners();
  }

  void setVisualizerColor(Color color) {
    _visualizerData = _visualizerData.copyWith(primaryColor: color);
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}