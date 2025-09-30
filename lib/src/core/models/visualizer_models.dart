import 'package:flutter/material.dart';

enum VisualizerStyle {
  bars,
  waveform,
  oscilloscope,
  spectrum,
}

class VisualizerData {
  final List<double> amplitudes;
  final double currentProgress;
  final int sampleRate;
  final Color primaryColor;
  final Color secondaryColor;
  final VisualizerStyle style;
  final bool isPlaying;

  VisualizerData({
    required this.amplitudes,
    required this.currentProgress,
    this.sampleRate = 200,
    this.primaryColor = const Color(0xFF1DB954),
    this.secondaryColor = const Color(0xFF39FF14),
    this.style = VisualizerStyle.oscilloscope,
    this.isPlaying = false,
  });

  VisualizerData copyWith({
    List<double>? amplitudes,
    double? currentProgress,
    int? sampleRate,
    Color? primaryColor,
    Color? secondaryColor,
    VisualizerStyle? style,
    bool? isPlaying,
  }) {
    return VisualizerData(
      amplitudes: amplitudes ?? this.amplitudes,
      currentProgress: currentProgress ?? this.currentProgress,
      sampleRate: sampleRate ?? this.sampleRate,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      style: style ?? this.style,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

class WaveformSample {
  final double time;
  final double amplitude;
  final double frequency;
  final List<double> spectrum;

  WaveformSample({
    required this.time,
    required this.amplitude,
    this.frequency = 0.0,
    this.spectrum = const [],
  });
}