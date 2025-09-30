import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.graphic_eq,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(duration: 1500.ms, color: Theme.of(context).colorScheme.primary),
            
            const SizedBox(height: 24),
            
            Text(
              'Spotify Visualizer',
              style: Theme.of(context).textTheme.headlineMedium,
            )
            .animate(delay: 300.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 8),
            
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyMedium,
            )
            .animate(delay: 600.ms)
            .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
            .animate(delay: 900.ms)
            .fadeIn(duration: 600.ms)
            .scaleX(begin: 0, end: 1),
          ],
        ),
      ),
    );
  }
}