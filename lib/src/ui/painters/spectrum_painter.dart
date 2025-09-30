import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/models/visualizer_models.dart';

class SpectrumPainter extends CustomPainter {
  final VisualizerData data;

  SpectrumPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.amplitudes.isEmpty) return;

    final spectrumBands = min(32, data.amplitudes.length ~/ 2);
    final bandWidth = size.width / spectrumBands;

    // Draw frequency bands
    for (int i = 0; i < spectrumBands; i++) {
      final startIndex = (i * data.amplitudes.length / spectrumBands).round();
      final endIndex = ((i + 1) * data.amplitudes.length / spectrumBands).round();
      
      // Calculate average amplitude for this frequency band
      double avgAmplitude = 0.0;
      for (int j = startIndex; j < endIndex && j < data.amplitudes.length; j++) {
        avgAmplitude += data.amplitudes[j];
      }
      avgAmplitude /= (endIndex - startIndex);
      
      // Add frequency-based coloring and animation
      final frequency = (i / spectrumBands) * 20000; // Approximate frequency in Hz
      final color = _getFrequencyColor(frequency, avgAmplitude);
      
      // Animation effect
      final animationPhase = data.currentProgress * 2 * pi + i * 0.2;
      final animationMultiplier = data.isPlaying 
          ? 1.0 + sin(animationPhase) * 0.1 
          : 0.8;
      
      final barHeight = avgAmplitude * size.height * animationMultiplier;
      final x = i * bandWidth;
      final y = size.height - barHeight;
      
      // Draw frequency bar
      _drawFrequencyBar(canvas, Rect.fromLTWH(x, y, bandWidth * 0.8, barHeight), color);
    }

    // Draw frequency labels
    _drawFrequencyLabels(canvas, size, spectrumBands);
  }

  Color _getFrequencyColor(double frequency, double amplitude) {
    // Color mapping based on frequency ranges
    if (frequency < 250) {
      // Bass - red tones
      return Color.lerp(Colors.red.withOpacity(0.3), Colors.red, amplitude) ?? Colors.red;
    } else if (frequency < 4000) {
      // Midrange - green/yellow tones
      return Color.lerp(data.primaryColor.withOpacity(0.3), data.primaryColor, amplitude) ?? data.primaryColor;
    } else {
      // Treble - blue/cyan tones
      return Color.lerp(Colors.cyan.withOpacity(0.3), Colors.cyan, amplitude) ?? Colors.cyan;
    }
  }

  void _drawFrequencyBar(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create gradient for the bar
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.3),
      ],
    );

    paint.shader = gradient.createShader(rect);

    // Draw rounded rectangle
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
    canvas.drawRRect(rrect, paint);

    // Add glow effect for high amplitudes
    if (rect.height > rect.width * 3) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawRRect(rrect, glowPaint);
    }
  }

  void _drawFrequencyLabels(Canvas canvas, Size size, int spectrumBands) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final frequencies = ['60', '250', '1K', '4K', '16K'];
    final positions = [0.1, 0.3, 0.5, 0.7, 0.9];

    for (int i = 0; i < frequencies.length; i++) {
      textPainter.text = TextSpan(
        text: frequencies[i],
        style: TextStyle(
          color: data.primaryColor.withOpacity(0.6),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      
      textPainter.layout();
      
      final x = positions[i] * size.width - textPainter.width / 2;
      final y = size.height - textPainter.height - 4;
      
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(SpectrumPainter oldDelegate) {
    return oldDelegate.data.currentProgress != data.currentProgress ||
           oldDelegate.data.isPlaying != data.isPlaying ||
           oldDelegate.data.amplitudes != data.amplitudes;
  }
}