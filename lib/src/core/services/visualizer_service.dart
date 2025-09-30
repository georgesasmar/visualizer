import 'dart:math';

import '../models/spotify_models.dart';
import '../models/visualizer_models.dart';

class VisualizerService {
  static const int defaultSampleCount = 200;
  
  final Map<String, List<WaveformSample>> _cache = {};

  List<WaveformSample> generateWaveform(
    AudioAnalysis analysis,
    AudioFeatures features, {
    int sampleCount = defaultSampleCount,
  }) {
    final trackId = features.durationMs.toString();
    
    if (_cache.containsKey(trackId)) {
      return _cache[trackId]!;
    }

    final samples = <WaveformSample>[];
    final duration = analysis.track.duration;
    final timeStep = duration / sampleCount;

    for (int i = 0; i < sampleCount; i++) {
      final time = i * timeStep;
      final amplitude = _calculateAmplitudeAtTime(analysis, time, features);
      final frequency = _calculateFrequencyAtTime(analysis, time, features.tempo);
      final spectrum = _calculateSpectrumAtTime(analysis, time);

      samples.add(WaveformSample(
        time: time,
        amplitude: amplitude,
        frequency: frequency,
        spectrum: spectrum,
      ));
    }

    _cache[trackId] = samples;
    return samples;
  }

  List<double> generateSimplifiedWaveform(
    AudioAnalysis analysis,
    AudioFeatures features, {
    int sampleCount = defaultSampleCount,
  }) {
    final waveform = generateWaveform(analysis, features, sampleCount: sampleCount);
    return waveform.map((sample) => sample.amplitude).toList();
  }

  double _calculateAmplitudeAtTime(
    AudioAnalysis analysis,
    double time,
    AudioFeatures features,
  ) {
    // Find the segment that contains this time
    final segment = analysis.segments.where((s) => 
      s.start <= time && (s.start + s.duration) > time
    ).firstOrNull;

    if (segment == null) {
      return 0.5; // Default amplitude
    }

    // Calculate position within the segment (0.0 to 1.0)
    final segmentProgress = (time - segment.start) / segment.duration;

    // Interpolate loudness based on segment progress
    double loudness;
    if (segmentProgress <= segment.loudnessMaxTime / segment.duration) {
      // Before peak
      loudness = _lerp(segment.loudnessStart, segment.loudnessMax, 
                      segmentProgress / (segment.loudnessMaxTime / segment.duration));
    } else {
      // After peak
      final afterPeakProgress = (segmentProgress - (segment.loudnessMaxTime / segment.duration)) /
                               (1.0 - (segment.loudnessMaxTime / segment.duration));
      loudness = _lerp(segment.loudnessMax, segment.loudnessEnd, afterPeakProgress);
    }

    // Normalize loudness to 0-1 range (Spotify loudness is typically -60 to 0 dB)
    final normalizedLoudness = (loudness + 60) / 60;
    
    // Apply energy and danceability as modifiers
    final energyModifier = features.energy * 0.3 + 0.7;
    final danceabilityModifier = features.danceability * 0.2 + 0.8;
    
    final amplitude = (normalizedLoudness * energyModifier * danceabilityModifier).clamp(0.0, 1.0);
    
    // Add some harmonic content based on pitches
    if (segment.pitches.isNotEmpty) {
      final pitchContribution = segment.pitches.reduce((a, b) => a + b) / segment.pitches.length;
      return (amplitude + pitchContribution * 0.1).clamp(0.0, 1.0);
    }
    
    return amplitude;
  }

  double _calculateFrequencyAtTime(
    AudioAnalysis analysis,
    double time,
    double baseTempo,
  ) {
    final segment = analysis.segments.where((s) => 
      s.start <= time && (s.start + s.duration) > time
    ).firstOrNull;

    if (segment == null || segment.pitches.isEmpty) {
      return baseTempo / 60; // Convert BPM to Hz
    }

    // Find dominant pitch class (0-11)
    double maxPitch = 0;
    int dominantPitchClass = 0;
    for (int i = 0; i < segment.pitches.length; i++) {
      if (segment.pitches[i] > maxPitch) {
        maxPitch = segment.pitches[i];
        dominantPitchClass = i;
      }
    }

    // Convert pitch class to approximate frequency (simplified)
    final baseFreq = 440 * pow(2, (dominantPitchClass - 9) / 12); // A4 = 440Hz
    return baseFreq.toDouble();
  }

  List<double> _calculateSpectrumAtTime(AudioAnalysis analysis, double time) {
    final segment = analysis.segments.where((s) => 
      s.start <= time && (s.start + s.duration) > time
    ).firstOrNull;

    if (segment == null || segment.timbre.isEmpty) {
      return List.filled(12, 0.5); // Default spectrum
    }

    // Normalize timbre values to 0-1 range
    final minTimbre = segment.timbre.reduce(min);
    final maxTimbre = segment.timbre.reduce(max);
    final range = maxTimbre - minTimbre;
    
    if (range == 0) return segment.timbre.map((t) => 0.5).toList();
    
    return segment.timbre.map((t) => (t - minTimbre) / range).toList();
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  void clearCache() {
    _cache.clear();
  }
}

extension ListExtensions<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}