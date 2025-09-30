import 'package:flutter/material.dart';

import '../../core/models/visualizer_models.dart';
import '../../core/theme/app_theme.dart';

class ControlPanel extends StatelessWidget {
  final VisualizerData visualizerData;
  final Function(VisualizerStyle) onStyleChanged;
  final Function(Color) onColorChanged;

  const ControlPanel({
    super.key,
    required this.visualizerData,
    required this.onStyleChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visualizer Controls',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 16),
            
            // Style selector
            Text(
              'Style',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: VisualizerStyle.values.map((style) {
                  final isSelected = visualizerData.style == style;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getStyleName(style)),
                      selected: isSelected,
                      onSelected: (_) => onStyleChanged(style),
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Color selector
            Text(
              'Color',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppTheme.visualizerColorPresets.map((color) {
                  final isSelected = visualizerData.primaryColor.value == color.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onColorChanged(color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current selection info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: visualizerData.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current: ${_getStyleName(visualizerData.style)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStyleName(VisualizerStyle style) {
    switch (style) {
      case VisualizerStyle.bars:
        return 'Bars';
      case VisualizerStyle.waveform:
        return 'Waveform';
      case VisualizerStyle.oscilloscope:
        return 'Oscilloscope';
      case VisualizerStyle.spectrum:
        return 'Spectrum';
    }
  }
}