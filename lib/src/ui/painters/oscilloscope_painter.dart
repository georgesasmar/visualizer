import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/models/visualizer_models.dart';

class OscilloscopePainter extends CustomPainter {
  final VisualizerData data;

  OscilloscopePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.amplitudes.isEmpty) return;

    final paint = Paint()
      ..color = data.primaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = data.primaryColor.withOpacity(0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    final glowPath = Path();
    
    final centerY = size.height / 2;
    final amplitudeScale = size.height * 0.4;
    final widthStep = size.width / (data.amplitudes.length - 1);

    // Calculate viewport based on current progress
    final viewportSize = (data.amplitudes.length * 0.3).round();
    final progressIndex = (data.currentProgress * data.amplitudes.length).round();
    final startIndex = (progressIndex - viewportSize ~/ 2).clamp(0, data.amplitudes.length - viewportSize);
    
    bool firstPoint = true;
    
    for (int i = 0; i < viewportSize && (startIndex + i) < data.amplitudes.length; i++) {
      final amplitude = data.amplitudes[startIndex + i];
      final x = (i / (viewportSize - 1)) * size.width;
      
      // Add some noise and harmonics for more organic feel
      final noise = sin(x * 0.05 + data.currentProgress * 10) * 0.1;
      final harmonic = sin(x * 0.02 + data.currentProgress * 5) * 0.05;
      final finalAmplitude = amplitude + noise + harmonic;
      
      final y = centerY + (finalAmplitude - 0.5) * amplitudeScale * (data.isPlaying ? 1.0 : 0.5);
      
      if (firstPoint) {
        path.moveTo(x, y);
        glowPath.moveTo(x, y);
        firstPoint = false;
      } else {
        path.lineTo(x, y);
        glowPath.lineTo(x, y);
      }
    }

    // Draw glow effect
    canvas.drawPath(glowPath, glowPaint);
    
    // Draw main line
    canvas.drawPath(path, paint);

    // Draw scan line effect
    if (data.isPlaying) {
      _drawScanLine(canvas, size);
    }

    // Draw grid
    _drawGrid(canvas, size);
  }

  void _drawScanLine(Canvas canvas, Size size) {
    final scanLinePaint = Paint()
      ..color = data.primaryColor.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final scanX = data.currentProgress * size.width;
    canvas.drawLine(
      Offset(scanX, 0),
      Offset(scanX, size.height),
      scanLinePaint,
    );

    // Glow effect for scan line
    final glowPaint = Paint()
      ..color = data.primaryColor.withOpacity(0.2)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(scanX, 0),
      Offset(scanX, size.height),
      glowPaint,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = data.primaryColor.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (int i = 1; i < 5; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical lines
    for (int i = 1; i < 10; i++) {
      final x = (size.width / 10) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(OscilloscopePainter oldDelegate) {
    return oldDelegate.data.currentProgress != data.currentProgress ||
           oldDelegate.data.isPlaying != data.isPlaying ||
           oldDelegate.data.amplitudes != data.amplitudes;
  }
}