import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App icon and title
                Icon(
                  Icons.graphic_eq,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                )
                .animate()
                .scale(duration: 800.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 2000.ms, color: Theme.of(context).colorScheme.primary),
                
                const SizedBox(height: 32),
                
                Text(
                  'Spotify Visualizer',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 16),
                
                Text(
                  'Experience your music with\nold-school sound wave visualizations',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate(delay: 600.ms)
                .fadeIn(duration: 600.ms),
                
                const SizedBox(height: 64),
                
                // Features list
                _buildFeatureItem(
                  Icons.music_note,
                  'Real-time audio analysis',
                  'Visualize your currently playing tracks',
                  delay: 900,
                ),
                
                const SizedBox(height: 16),
                
                _buildFeatureItem(
                  Icons.widgets,
                  'Home screen widgets',
                  'See the visualizer on your home screen',
                  delay: 1200,
                ),
                
                const SizedBox(height: 16),
                
                _buildFeatureItem(
                  Icons.palette,
                  'Customizable styles',
                  'Choose from retro CRT, bars, and more',
                  delay: 1500,
                ),
                
                const Spacer(),
                
                // Auth button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    icon: _isAuthenticating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.login, size: 24),
                    label: Text(
                      _isAuthenticating ? 'Connecting...' : 'Connect with Spotify',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .animate(delay: 1800.ms)
                .fadeIn(duration: 600.ms)
                .scaleY(begin: 0.8, end: 1),
                
                const SizedBox(height: 16),
                
                Text(
                  'We\'ll redirect you to Spotify to authorize access to your currently playing music.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                )
                .animate(delay: 2100.ms)
                .fadeIn(duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle, {required int delay}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    )
    .animate(delay: delay.ms)
    .fadeIn(duration: 600.ms)
    .slideX(begin: 0.3, end: 0);
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final appState = context.read<AppStateProvider>();
      final success = await appState.authenticate();
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }
}