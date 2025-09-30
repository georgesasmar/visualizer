import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_visualizer/src/core/models/spotify_models.dart';
import 'package:spotify_visualizer/src/core/services/visualizer_service.dart';

void main() {
  group('VisualizerService Tests', () {
    late VisualizerService visualizerService;
    late AudioAnalysis testAnalysis;
    late AudioFeatures testFeatures;

    setUp(() {
      visualizerService = VisualizerService();
      
      // Create test data
      testAnalysis = AudioAnalysis(
        segments: [
          Segment(
            start: 0.0,
            duration: 1.0,
            confidence: 0.9,
            loudnessStart: -20.0,
            loudnessMax: -10.0,
            loudnessMaxTime: 0.5,
            loudnessEnd: -15.0,
            pitches: [0.5, 0.3, 0.8, 0.2, 0.6, 0.4, 0.7, 0.1, 0.9, 0.3, 0.5, 0.2],
            timbre: [10.0, 20.0, 15.0, 25.0, 30.0, 12.0, 18.0, 22.0, 8.0, 16.0, 14.0, 26.0],
          ),
          Segment(
            start: 1.0,
            duration: 1.0,
            confidence: 0.8,
            loudnessStart: -15.0,
            loudnessMax: -5.0,
            loudnessMaxTime: 0.3,
            loudnessEnd: -20.0,
            pitches: [0.3, 0.7, 0.2, 0.8, 0.4, 0.6, 0.1, 0.9, 0.3, 0.5, 0.7, 0.4],
            timbre: [15.0, 25.0, 20.0, 30.0, 35.0, 17.0, 23.0, 27.0, 13.0, 21.0, 19.0, 31.0],
          ),
        ],
        track: AudioAnalysisTrack(
          duration: 180.0,
          tempo: 120.0,
          timeSignature: 4,
          loudness: -12.0,
        ),
      );

      testFeatures = AudioFeatures(
        danceability: 0.8,
        energy: 0.7,
        key: 5,
        loudness: -8.0,
        mode: 1,
        speechiness: 0.05,
        acousticness: 0.2,
        instrumentalness: 0.1,
        liveness: 0.15,
        valence: 0.6,
        tempo: 120.0,
        durationMs: 180000,
        timeSignature: 4,
      );
    });

    test('should generate waveform with correct length', () {
      const expectedLength = 100;
      
      final waveform = visualizerService.generateWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: expectedLength,
      );

      expect(waveform.length, equals(expectedLength));
    });

    test('should generate simplified waveform', () {
      const expectedLength = 50;
      
      final amplitudes = visualizerService.generateSimplifiedWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: expectedLength,
      );

      expect(amplitudes.length, equals(expectedLength));
      expect(amplitudes.every((amplitude) => amplitude >= 0.0 && amplitude <= 1.0), isTrue);
    });

    test('should cache waveform data', () {
      const sampleCount = 50;
      
      // Generate waveform twice
      final waveform1 = visualizerService.generateWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: sampleCount,
      );
      
      final waveform2 = visualizerService.generateWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: sampleCount,
      );

      // Should return the same instance (cached)
      expect(identical(waveform1, waveform2), isTrue);
    });

    test('should clear cache', () {
      const sampleCount = 50;
      
      // Generate and cache waveform
      visualizerService.generateWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: sampleCount,
      );
      
      // Clear cache
      visualizerService.clearCache();
      
      // Generate again - should create new instance
      final waveform = visualizerService.generateWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: sampleCount,
      );

      expect(waveform.length, equals(sampleCount));
    });

    test('should handle empty segments', () {
      final emptyAnalysis = AudioAnalysis(
        segments: [],
        track: testAnalysis.track,
      );
      
      final waveform = visualizerService.generateSimplifiedWaveform(
        emptyAnalysis,
        testFeatures,
      );

      expect(waveform.length, equals(VisualizerService.defaultSampleCount));
      expect(waveform.every((amplitude) => amplitude == 0.5), isTrue);
    });

    test('should produce different amplitudes for different segments', () {
      final amplitudes = visualizerService.generateSimplifiedWaveform(
        testAnalysis,
        testFeatures,
        sampleCount: 20,
      );

      // Should have some variation in amplitudes
      final uniqueValues = amplitudes.toSet();
      expect(uniqueValues.length, greaterThan(1));
    });
  });
}