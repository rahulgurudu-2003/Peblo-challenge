import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/story_buddy_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/buddy_avatar.dart';
import 'widgets/confetti_overlay.dart';
import 'widgets/quiz_card.dart';
import 'widgets/story_card.dart';

class StoryBuddyScreen extends StatelessWidget {
  const StoryBuddyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StoryBuddyProvider>(
        builder: (context, provider, child) {
          final isSuccess = provider.phase == AppPhase.quizSuccess;

          return ConfettiOverlay(
            startCelebration: isSuccess,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Navigation Bar / Header
                      _buildHeader(context, provider),
                      const SizedBox(height: 18),
                      
                      // AI Buddy character space
                      Center(
                        child: BuddyAvatar(mood: provider.mood),
                      ),
                      const SizedBox(height: 24),
                      
                      // Animated Switcher to smoothly transition content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        switchInCurve: Curves.easeInOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _buildContentForPhase(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Beautiful Header/Top Bar
  Widget _buildHeader(BuildContext context, StoryBuddyProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Peblo",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Story Buddy",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Reset / Home Button
        if (provider.phase != AppPhase.idle)
          IconButton(
            onPressed: provider.restartApp,
            icon: const Icon(Icons.refresh_rounded, size: 28),
            color: AppTheme.textLight,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.optionBorder, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  // Returns the appropriate widget based on the active state machine phase
  Widget _buildContentForPhase(BuildContext context, StoryBuddyProvider provider) {
    switch (provider.phase) {
      // 1. Idle & Playback States
      case AppPhase.idle:
      case AppPhase.ttsLoading:
      case AppPhase.ttsPlaying:
        return StoryCard(
          key: const ValueKey("story_card"),
          phase: provider.phase,
          storyText: provider.storyText,
          onReadPressed: provider.readStory,
        );

      // 2. Loading Quiz State
      case AppPhase.quizLoading:
        return Card(
          key: const ValueKey("quiz_loading_card"),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Pip is thinking up a quiz...",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      // 3. Quiz Ready State
      case AppPhase.quizReady:
        if (provider.quizQuestion == null) return const SizedBox.shrink();
        return QuizCard(
          key: ValueKey("quiz_card_${provider.currentQuestionIndex}"),
          question: provider.quizQuestion!,
          shakeTrigger: provider.shakeTriggerCounter,
          onOptionSelected: provider.submitAnswer,
          currentQuestionIndex: provider.currentQuestionIndex,
          totalQuestions: provider.totalQuestions,
        );

      // 4. Success State (Celebration Card)
      case AppPhase.quizSuccess:
        return Card(
          key: const ValueKey("success_card"),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    "🎉 Brilliant! 🎉",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.correctColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "You found the shiny blue gear! Pip is so happy!",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: provider.restartApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.secondary.withOpacity(0.3),
                  ),
                  child: const Text(
                    "Play Again",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        );

      // 5. Failure State (Offline / Error Screen)
      case AppPhase.failure:
        return Card(
          key: const ValueKey("failure_card"),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppTheme.primary,
                  size: 56,
                ),
                const SizedBox(height: 18),
                const Text(
                  "Oops! Something went wrong",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  provider.errorMessage ?? "An unexpected connection problem occurred.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: provider.retry,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    "Try Again",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
