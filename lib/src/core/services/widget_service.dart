import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import '../models/spotify_models.dart';
import '../models/visualizer_models.dart';

class WidgetService {
  static const String widgetUpdateTask = 'widget_update_task';
  
  Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.example.spotify_visualizer');
  }

  Future<void> updateWidget({
    CurrentlyPlaying? currentTrack,
    VisualizerData? visualizerData,
  }) async {
    try {
      // Update widget data
      await HomeWidget.saveWidgetData<String>('track_name', currentTrack?.item?.name ?? '');
      await HomeWidget.saveWidgetData<String>('artist_name', currentTrack?.item?.artistNames ?? '');
      await HomeWidget.saveWidgetData<String>('album_image', currentTrack?.item?.album.imageUrl ?? '');
      await HomeWidget.saveWidgetData<bool>('is_playing', currentTrack?.isPlaying ?? false);
      await HomeWidget.saveWidgetData<int>('progress_ms', currentTrack?.progressMs ?? 0);
      await HomeWidget.saveWidgetData<int>('duration_ms', currentTrack?.item?.durationMs ?? 0);
      
      if (visualizerData != null) {
        await HomeWidget.saveWidgetData<String>('waveform_data', json.encode(visualizerData.amplitudes));
        await HomeWidget.saveWidgetData<int>('primary_color', visualizerData.primaryColor.value);
        await HomeWidget.saveWidgetData<int>('visualizer_style', visualizerData.style.index);
      }

      // Update timestamp for widget refresh logic
      await HomeWidget.saveWidgetData<int>('last_update', DateTime.now().millisecondsSinceEpoch);

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: 'SpotifyVisualizerWidget',
        androidName: 'SpotifyVisualizerWidget',
        iOSName: 'SpotifyVisualizerWidget',
      );

      print('Widget updated successfully');
    } catch (e) {
      print('Failed to update widget: $e');
    }
  }

  Future<void> schedulePeriodicUpdates() async {
    await Workmanager().registerPeriodicTask(
      'widget_update_periodic',
      widgetUpdateTask,
      frequency: const Duration(minutes: 15), // Minimum allowed by Android
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
    );
  }

  Future<void> scheduleOneTimeUpdate({Duration delay = const Duration(seconds: 5)}) async {
    await Workmanager().registerOneOffTask(
      'widget_update_${DateTime.now().millisecondsSinceEpoch}',
      widgetUpdateTask,
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  Future<void> cancelAllUpdates() async {
    await Workmanager().cancelAll();
  }

  // Widget data getters for background tasks
  static Future<Map<String, dynamic>?> getWidgetData() async {
    try {
      final trackName = await HomeWidget.getWidgetData<String>('track_name');
      final artistName = await HomeWidget.getWidgetData<String>('artist_name');
      final albumImage = await HomeWidget.getWidgetData<String>('album_image');
      final isPlaying = await HomeWidget.getWidgetData<bool>('is_playing');
      final progressMs = await HomeWidget.getWidgetData<int>('progress_ms');
      final durationMs = await HomeWidget.getWidgetData<int>('duration_ms');
      final waveformData = await HomeWidget.getWidgetData<String>('waveform_data');
      final primaryColor = await HomeWidget.getWidgetData<int>('primary_color');
      final visualizerStyle = await HomeWidget.getWidgetData<int>('visualizer_style');
      final lastUpdate = await HomeWidget.getWidgetData<int>('last_update');

      return {
        'track_name': trackName,
        'artist_name': artistName,
        'album_image': albumImage,
        'is_playing': isPlaying,
        'progress_ms': progressMs,
        'duration_ms': durationMs,
        'waveform_data': waveformData,
        'primary_color': primaryColor,
        'visualizer_style': visualizerStyle,
        'last_update': lastUpdate,
      };
    } catch (e) {
      print('Error getting widget data: $e');
      return null;
    }
  }
}