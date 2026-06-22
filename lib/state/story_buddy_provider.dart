import 'package:flutter/material.dart';
import '../data/models/quiz_question.dart';
import '../data/services/quiz_repository.dart';
import '../data/services/tts_service.dart';

enum AppPhase {
  idle,
  ttsLoading,
  ttsPlaying,
  quizLoading,
  quizReady,
  quizSuccess,
  failure,
}

enum BuddyMood {
  idle,
  talking,
  thinking,
  sad,
  happy,
}

class StoryBuddyProvider extends ChangeNotifier {
  final TtsService _ttsService = TtsService();
  final QuizRepository _quizRepository = QuizRepository();

  AppPhase _phase = AppPhase.idle;
  BuddyMood _mood = BuddyMood.idle;
  
  String _storyText = "Tap the button below and Pip will tell you a magical story! 🤖✨";
  List<QuizQuestion> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  QuizQuestion? _quizQuestion;
  
  String? _errorMessage;
  int _shakeTriggerCounter = 0;

  // Getters
  AppPhase get phase => _phase;
  BuddyMood get mood => _mood;
  String get storyText => _storyText;
  QuizQuestion? get quizQuestion => _quizQuestion;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _quizQuestions.length;
  String? get errorMessage => _errorMessage;
  int get shakeTriggerCounter => _shakeTriggerCounter;

  StoryBuddyProvider() {
    _setupTtsHandlers();
  }

  void _setupTtsHandlers() {
    _ttsService.setStartHandler(() {
      _phase = AppPhase.ttsPlaying;
      _mood = BuddyMood.talking;
      notifyListeners();
    });

    _ttsService.setCompletionHandler(() {
      // Narration finished! Now load and show the quiz directly
      _startQuiz();
    });

    _ttsService.setErrorHandler((errorMsg) {
      _handleFailure("TTS Engine Error: $errorMsg");
    });
  }

  // Regular expression to strip emojis from spoken text so TTS reads clean sentences
  String _stripEmojis(String text) {
    final RegExp emojiRegExp = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{1F1E6}-\u{1F1FF}]',
      unicode: true,
    );
    return text.replaceAll(emojiRegExp, '');
  }

  Future<void> readStory() async {
    if (_phase == AppPhase.ttsLoading || _phase == AppPhase.ttsPlaying) return;

    _phase = AppPhase.ttsLoading;
    _mood = BuddyMood.thinking;
    notifyListeners();

    try {
      // Fetch a random story bundle containing short text and multiple matching questions
      final bundle = await _quizRepository.fetchRandomStory();
      _storyText = bundle.storyText;
      _quizQuestions = bundle.questions;
      notifyListeners();

      final cleanText = _stripEmojis(_storyText);
      await _ttsService.speak(cleanText);
    } catch (e) {
      _handleFailure("Could not load the story. Please check your internet connection.");
    }
  }

  void _startQuiz() {
    _currentQuestionIndex = 0;
    if (_quizQuestions.isNotEmpty) {
      _quizQuestion = _quizQuestions[_currentQuestionIndex];
      _phase = AppPhase.quizReady;
      _mood = BuddyMood.idle;
    } else {
      _phase = AppPhase.idle;
      _mood = BuddyMood.idle;
    }
    notifyListeners();
  }

  void submitAnswer(String selectedOption) {
    if (_quizQuestion == null || _phase != AppPhase.quizReady) return;

    if (selectedOption.trim().toLowerCase() ==
        _quizQuestion!.answer.trim().toLowerCase()) {
      // Correct!
      _mood = BuddyMood.happy;
      notifyListeners();

      // Pause for 1.5 seconds so the child sees the visual checkmark animation
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_phase == AppPhase.quizReady) {
          if (_currentQuestionIndex < _quizQuestions.length - 1) {
            // Load next question in the bundle
            _currentQuestionIndex++;
            _quizQuestion = _quizQuestions[_currentQuestionIndex];
            _mood = BuddyMood.idle;
            notifyListeners();
          } else {
            // Successfully completed all questions!
            _phase = AppPhase.quizSuccess;
            _mood = BuddyMood.happy;
            notifyListeners();
          }
        }
      });
    } else {
      // Incorrect! Trigger shake and set mood to sad briefly
      _mood = BuddyMood.sad;
      _shakeTriggerCounter++;
      notifyListeners();

      // Return to idle mood after 1.5 seconds so buddy doesn't stay sad forever
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_phase == AppPhase.quizReady) {
          _mood = BuddyMood.idle;
          notifyListeners();
        }
      });
    }
  }

  void _handleFailure(String message) {
    _phase = AppPhase.failure;
    _mood = BuddyMood.sad;
    _errorMessage = message;
    _ttsService.stop();
    notifyListeners();
  }

  Future<void> retry() async {
    _errorMessage = null;
    _quizQuestions = [];
    _quizQuestion = null;
    await readStory();
  }

  void restartApp() {
    _phase = AppPhase.idle;
    _mood = BuddyMood.idle;
    _storyText = "Tap the button below and Pip will tell you another magical story! 🤖✨";
    _quizQuestions = [];
    _currentQuestionIndex = 0;
    _quizQuestion = null;
    _errorMessage = null;
    _ttsService.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}
