import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/providers/app_state_provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/home_screen.dart';

class SpotifyVisualizerApp extends StatelessWidget {
  const SpotifyVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Spotify Visualizer',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          home: _buildHome(appState),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildHome(AppStateProvider appState) {
    switch (appState.appStatus) {
      case AppStatus.loading:
        return const SplashScreen();
      case AppStatus.unauthenticated:
        return const AuthScreen();
      case AppStatus.authenticated:
        return const HomeScreen();
    }
  }
}