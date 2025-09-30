import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/models/visualizer_models.dart';

class BarsPainter extends CustomPainter {
  final VisualizerData data;

  BarsPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.amplitudes.isEmpty) return;

    final barCount = min(64, data.amplitudes.length);
    final barWidth = (size.width / barCount) * 0.8;
    final barSpacing = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final amplitude = data.amplitudes[(i * data.amplitudes.length / barCount).round()];
      
      // Add some animation based on current progress
      final animationOffset = sin(data.currentProgress * 2 * pi + i * 0.1) * 0.1;
      final finalAmplitude = (amplitude + animationOffset).clamp(0.0, 1.0);
      
      final barHeight = finalAmplitude * size.height * (data.isPlaying ? 1.0 : 0.6);
      final x = i * barSpacing + (barSpacing - barWidth) / 2;
      final y = size.height - barHeight;

      // Create gradient for each bar
      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          data.primaryColor,
          data.primaryColor.withOpacity(0.6),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      // Draw bar with rounded corners
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(barWidth / 4),
      );
      
      canvas.drawRRect(rrect, paint);

      // Add glow effect
      if (data.isPlaying && finalAmplitude > 0.7) {
        final glowPaint = Paint()
          ..color = data.primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawRRect(rrect, glowPaint);
      }
    }

    // Draw reflection
    _drawReflection(canvas, size, barCount, barWidth, barSpacing);
  }

  void _drawReflection(Canvas canvas, Size size, int barCount, double barWidth, double barSpacing) {
    final reflectionHeight = size.height * 0.3;
    
    for (int i = 0; i < barCount; i++) {
      final amplitude = data.amplitudes[(i * data.amplitudes.length / barCount).round()];
      final animationOffset = sin(data.currentProgress * 2 * pi + i * 0.1) * 0.1;
      final finalAmplitude = (amplitude + animationOffset).clamp(0.0, 1.0);
      
      final barHeight = finalAmplitude * reflectionHeight * (data.isPlaying ? 0.5 : 0.3);
      final x = i * barSpacing + (barSpacing - barWidth) / 2;
      final y = size.height;

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          data.primaryColor.withOpacity(0.3),
          data.primaryColor.withOpacity(0.0),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(barWidth / 4),
      );
      
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(BarsPainter oldDelegate) {
    return oldDelegate.data.currentProgress != data.currentProgress ||
           oldDelegate.data.isPlaying != data.isPlaying ||
           oldDelegate.data.amplitudes != data.amplitudes;
  }
}