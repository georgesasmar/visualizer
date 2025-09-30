import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/visualizer_models.dart';
import '../painters/oscilloscope_painter.dart';
import '../painters/bars_painter.dart';
import '../painters/waveform_painter.dart';
import '../painters/spectrum_painter.dart';

class VisualizerWidget extends StatefulWidget {
  final VisualizerData visualizerData;

  const VisualizerWidget({
    super.key,
    required this.visualizerData,
  });

  @override
  State<VisualizerWidget> createState() => _VisualizerWidgetState();
}

class _VisualizerWidgetState extends State<VisualizerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.visualizerData.isPlaying) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(VisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visualizerData.isPlaying != oldWidget.visualizerData.isPlaying) {
      if (widget.visualizerData.isPlaying) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visualizerData.amplitudes.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              colors: [
                widget.visualizerData.primaryColor.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _getPainter(),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  CustomPainter _getPainter() {
    final animatedData = widget.visualizerData.copyWith(
      currentProgress: widget.visualizerData.currentProgress + 
                     (_animation.value * 0.01), // Small animation offset
    );

    switch (widget.visualizerData.style) {
      case VisualizerStyle.bars:
        return BarsPainter(animatedData);
      case VisualizerStyle.waveform:
        return WaveformPainter(animatedData);
      case VisualizerStyle.oscilloscope:
        return OscilloscopePainter(animatedData);
      case VisualizerStyle.spectrum:
        return SpectrumPainter(animatedData);
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.graphic_eq,
            size: 64,
            color: Colors.grey[400],
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: widget.visualizerData.primaryColor),
          
          const SizedBox(height: 16),
          
          Text(
            'Waiting for audio data...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          )
          .animate(delay: 500.ms)
          .fadeIn(),
        ],
      ),
    );
  }
}