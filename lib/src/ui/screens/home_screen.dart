import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state_provider.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/visualizer_widget.dart';
import '../widgets/control_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Visualizer'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showSettingsBottomSheet(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Now playing card
                NowPlayingCard(
                  currentlyPlaying: appState.currentlyPlaying,
                ),
                
                const SizedBox(height: 24),
                
                // Main visualizer
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: appState.visualizerData.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: VisualizerWidget(
                      visualizerData: appState.visualizerData,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Control panel
                ControlPanel(
                  visualizerData: appState.visualizerData,
                  onStyleChanged: appState.setVisualizerStyle,
                  onColorChanged: appState.setVisualizerColor,
                ),
                
                const SizedBox(height: 24),
                
                // Status information
                _buildStatusInfo(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context, AppStateProvider appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  appState.isPlaying ? Icons.play_arrow : Icons.pause,
                  color: appState.isPlaying ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  appState.isPlaying ? 'Playing' : 'Paused',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.widgets, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Widget updates enabled',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            if (appState.currentlyPlaying?.item != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Audio analysis loaded',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              const SizedBox(height: 24),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('Theme'),
                      subtitle: const Text('Toggle dark/light mode'),
                      trailing: Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (value) {
                          final appState = context.read<AppStateProvider>();
                          appState.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Disconnect'),
                      subtitle: const Text('Sign out from Spotify'),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      subtitle: const Text('Version 1.0.0'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect from Spotify'),
        content: const Text('Are you sure you want to sign out? You\'ll need to reconnect to use the visualizer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppStateProvider>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}