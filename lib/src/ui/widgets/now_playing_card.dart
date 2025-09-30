import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/spotify_models.dart';

class NowPlayingCard extends StatelessWidget {
  final CurrentlyPlaying? currentlyPlaying;

  const NowPlayingCard({
    super.key,
    required this.currentlyPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final track = currentlyPlaying?.item;
    
    if (track == null) {
      return _buildEmptyState(context);
    }

    final progress = currentlyPlaying!.progressMs != null 
        ? currentlyPlaying!.progressMs! / track.durationMs 
        : 0.0;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Album artwork
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                    image: track.album.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(track.album.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: track.album.imageUrl == null
                      ? const Icon(Icons.music_note, size: 40, color: Colors.grey)
                      : null,
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(),
                
                const SizedBox(width: 16),
                
                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                      .animate(delay: 300.ms)
                      .slideX(begin: 0.3, end: 0)
                      .fadeIn(),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        track.artistNames,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      .animate(delay: 450.ms)
                      .slideX(begin: 0.3, end: 0)
                      .fadeIn(),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        track.album.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                      .animate(delay: 600.ms)
                      .slideX(begin: 0.3, end: 0)
                      .fadeIn(),
                    ],
                  ),
                ),
                
                // Playing indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentlyPlaying!.isPlaying
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    currentlyPlaying!.isPlaying ? Icons.play_arrow : Icons.pause,
                    color: currentlyPlaying!.isPlaying
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    size: 24,
                  ),
                )
                .animate(delay: 750.ms)
                .scale(curve: Curves.elasticOut)
                .fadeIn(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 4,
                )
                .animate(delay: 900.ms)
                .scaleX(begin: 0, end: 1, curve: Curves.easeOutCubic),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentlyPlaying!.progressMs ?? 0),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatDuration(track.durationMs),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
                .animate(delay: 1050.ms)
                .fadeIn(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.music_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No track playing',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start playing music on Spotify to see the visualizer',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms)
    .scaleY(begin: 0.8, end: 1, curve: Curves.easeOutBack);
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}