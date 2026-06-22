import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/story_buddy_provider.dart';
import 'ui/story_buddy_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PebloChallengeApp());
}

class PebloChallengeApp extends StatelessWidget {
  const PebloChallengeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryBuddyProvider(),
      child: MaterialApp(
        title: 'Peblo Story Buddy',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const StoryBuddyScreen(),
      ),
    );
  }
}
