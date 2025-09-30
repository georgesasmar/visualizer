import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_visualizer/src/core/models/visualizer_models.dart';
import 'package:spotify_visualizer/src/ui/widgets/visualizer_widget.dart';

void main() {
  group('VisualizerWidget Tests', () {
    testWidgets('should display empty state when no amplitudes', (WidgetTester tester) async {
      final visualizerData = VisualizerData(
        amplitudes: [],
        currentProgress: 0.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisualizerWidget(visualizerData: visualizerData),
          ),
        ),
      );

      expect(find.text('Waiting for audio data...'), findsOneWidget);
      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
    });

    testWidgets('should display visualizer when amplitudes provided', (WidgetTester tester) async {
      final visualizerData = VisualizerData(
        amplitudes: List.generate(50, (index) => 0.5 + (index % 10) * 0.05),
        currentProgress: 0.3,
        isPlaying: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisualizerWidget(visualizerData: visualizerData),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
      expect(find.text('Waiting for audio data...'), findsNothing);
    });

    testWidgets('should respond to visualizer style changes', (WidgetTester tester) async {
      VisualizerData visualizerData = VisualizerData(
        amplitudes: List.filled(50, 0.7),
        currentProgress: 0.0,
        style: VisualizerStyle.bars,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return VisualizerWidget(visualizerData: visualizerData);
              },
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);

      // Simulate style change
      visualizerData = visualizerData.copyWith(style: VisualizerStyle.waveform);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisualizerWidget(visualizerData: visualizerData),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle color changes', (WidgetTester tester) async {
      final visualizerData = VisualizerData(
        amplitudes: List.filled(50, 0.7),
        currentProgress: 0.0,
        primaryColor: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisualizerWidget(visualizerData: visualizerData),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(customPaint.painter, isNotNull);
    });
  });
}