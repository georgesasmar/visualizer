import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/models/visualizer_models.dart';

class WaveformPainter extends CustomPainter {
  final VisualizerData data;

  WaveformPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.amplitudes.isEmpty) return;

    final centerY = size.height / 2;
    final amplitudeScale = size.height * 0.4;
    
    // Draw waveform
    _drawWaveform(canvas, size, centerY, amplitudeScale);
    
    // Draw progress indicator
    if (data.isPlaying) {
      _drawProgressIndicator(canvas, size);
    }
  }

  void _drawWaveform(Canvas canvas, Size size, double centerY, double amplitudeScale) {
    final paint = Paint()
      ..color = data.primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = data.primaryColor.withOpacity(0.2)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    final glowPath = Path();
    
    final widthStep = size.width / data.amplitudes.length;

    // Create waveform path
    path.moveTo(0, centerY);
    glowPath.moveTo(0, centerY);

    for (int i = 0; i < data.amplitudes.length; i++) {
      final amplitude = data.amplitudes[i];
      final x = i * widthStep;
      
      // Add some variation based on progress for animation
      final progressEffect = sin(data.currentProgress * 4 * pi + i * 0.05) * 0.05;
      final finalAmplitude = amplitude + progressEffect;
      
      final topY = centerY - (finalAmplitude * amplitudeScale * (data.isPlaying ? 1.0 : 0.7));
      final bottomY = centerY + (finalAmplitude * amplitudeScale * (data.isPlaying ? 1.0 : 0.7));
      
      path.lineTo(x, topY);
      glowPath.lineTo(x, topY);
    }

    // Complete the top path
    for (int i = data.amplitudes.length - 1; i >= 0; i--) {
      final amplitude = data.amplitudes[i];
      final x = i * widthStep;
      
      final progressEffect = sin(data.currentProgress * 4 * pi + i * 0.05) * 0.05;
      final finalAmplitude = amplitude + progressEffect;
      
      final bottomY = centerY + (finalAmplitude * amplitudeScale * (data.isPlaying ? 1.0 : 0.7));
      
      path.lineTo(x, bottomY);
      glowPath.lineTo(x, bottomY);
    }

    path.close();
    glowPath.close();

    // Draw glow
    canvas.drawPath(glowPath, glowPaint);
    
    // Draw main waveform
    canvas.drawPath(path, paint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = data.primaryColor.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );
  }

  void _drawProgressIndicator(Canvas canvas, Size size) {
    final progressX = data.currentProgress * size.width;
    
    final progressPaint = Paint()
      ..color = data.secondaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, size.height),
      progressPaint,
    );

    // Progress indicator glow
    final glowPaint = Paint()
      ..color = data.secondaryColor.withOpacity(0.4)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.data.currentProgress != data.currentProgress ||
           oldDelegate.data.isPlaying != data.isPlaying ||
           oldDelegate.data.amplitudes != data.amplitudes;
  }
}