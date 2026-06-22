import 'package:flutter/material.dart';
import '../../state/story_buddy_provider.dart';
import '../theme/app_theme.dart';

class StoryCard extends StatefulWidget {
  final AppPhase phase;
  final String storyText;
  final VoidCallback onReadPressed;

  const StoryCard({
    Key? key,
    required this.phase,
    required this.storyText,
    required this.onReadPressed,
  }) : super(key: key);

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.phase == AppPhase.idle) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase == AppPhase.idle) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.phase == AppPhase.ttsLoading;
    bool isPlaying = widget.phase == AppPhase.ttsPlaying;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.buddyPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "📖 PIP'S TALE",
                    style: TextStyle(
                      color: AppTheme.buddyPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            
            // Story Text
            Text(
              widget.storyText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isPlaying ? AppTheme.buddyPrimary : AppTheme.textDark,
                shadows: isPlaying
                    ? [
                        Shadow(
                          color: AppTheme.buddyPrimary.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // TTS Control Button (Gently pulses when idle to prompt interaction)
            ScaleTransition(
              scale: _scaleAnimation,
              child: ElevatedButton(
                onPressed: (isLoading || isPlaying) ? null : widget.onReadPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                  disabledForegroundColor: Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: isPlaying ? 0 : 4,
                  shadowColor: AppTheme.primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButtonContent(context, isLoading, isPlaying),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, bool isLoading, bool isPlaying) {
    if (isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "Tuning Pip's Voice...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    if (isPlaying) {
      return const Row(
        children: [
          Icon(Icons.volume_up_rounded, size: 24),
          SizedBox(width: 10),
          Text(
            "Pip is Narrating...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return const Row(
      children: [
        Icon(Icons.play_arrow_rounded, size: 24),
        SizedBox(width: 10),
        Text(
          "Read Me a Story",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
