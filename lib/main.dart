import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:home_widget/home_widget.dart';

import 'src/app.dart';
import 'src/core/services/spotify_service.dart';
import 'src/core/services/storage_service.dart';
import 'src/core/services/widget_service.dart';
import 'src/core/services/visualizer_service.dart';
import 'src/core/providers/app_state_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final widgetService = WidgetService();
      await widgetService.updateWidget();
      return Future.value(true);
    } catch (e) {
      print('Background task failed: $e');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background work manager
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  
  // Initialize home widget
  await HomeWidget.setAppGroupId('group.com.example.spotify_visualizer');
  
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<SpotifyService>(
          create: (context) => SpotifyService(
            storageService: context.read<StorageService>(),
          ),
        ),
        Provider<VisualizerService>(
          create: (_) => VisualizerService(),
        ),
        Provider<WidgetService>(
          create: (context) => WidgetService(),
        ),
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(
            spotifyService: context.read<SpotifyService>(),
            visualizerService: context.read<VisualizerService>(),
            widgetService: context.read<WidgetService>(),
          ),
        ),
      ],
      child: const SpotifyVisualizerApp(),
    ),
  );
}