import 'dart:convert';
import 'dart:math' as math;
import '../models/quiz_question.dart';

class QuizRepository {
  // Simulates a backend API response returning a random story bundle
  Future<StoryBundle> fetchRandomStory({bool simulateFailure = false}) async {
    // Simulate network delay of 1.2 seconds
    await Future.delayed(const Duration(milliseconds: 1200));

    if (simulateFailure) {
      throw Exception("Unable to load the story. Please check your network connection.");
    }

    // Dynamic JSON payload containing multiple story bundles with shorter texts and emojis.
    // The first question matches the challenge specification JSON exactly.
    const String responseJson = '''
    [
      {
        "storyText": "Once upon a time, a clever little robot named Pip 🤖 lost his shiny blue gear ⚙️ in the Whispering Woods... 🌲",
        "questions": [
          {
            "question": "What colour was Pip the Robot's lost gear?",
            "options": ["Red", "Green", "Blue", "Yellow"],
            "answer": "Blue"
          },
          {
            "question": "Who did Pip meet in the Whispering Woods?",
            "options": ["Sammy the Squirrel", "A friendly bear", "A blue bird", "A busy ant"],
            "answer": "Sammy the Squirrel"
          },
          {
            "question": "Where was the gear hidden?",
            "options": ["In the river", "Under a red mushroom", "On a high tree", "In a hollow log"],
            "answer": "Under a red mushroom"
          }
        ]
      },
      {
        "storyText": "Barnaby the Bunny 🐰 was looking for his magic golden acorn 🌰 near the giggling waterfall... 💦",
        "questions": [
          {
            "question": "What was Barnaby the Bunny looking for?",
            "options": ["A juicy carrot", "A magic golden acorn", "A silver coin", "A green leaf"],
            "answer": "A magic golden acorn"
          },
          {
            "question": "Who helped Barnaby look for the acorn?",
            "options": ["Tilly the Turtle", "Sammy the Squirrel", "A wise owl", "A friendly fox"],
            "answer": "Tilly the Turtle"
          },
          {
            "question": "Where did they find the acorn?",
            "options": ["Under flat gray stones", "In the waterfall", "Under a pink flower", "Inside a burrow"],
            "answer": "Under a pink flower"
          }
        ]
      },
      {
        "storyText": "Leo the Lion cub 🦁 wanted to catch a glowing star 🌟 that fell from the sky... ☁️",
        "questions": [
          {
            "question": "What did Leo the Lion cub want to catch?",
            "options": ["A glowing star", "A shiny firefly", "A yellow butterfly", "A silver bubble"],
            "answer": "A glowing star"
          },
          {
            "question": "Who did Leo ask for help?",
            "options": ["Oliver the Owl", "Barnaby the Bunny", "A tall giraffe", "A happy monkey"],
            "answer": "Oliver the Owl"
          },
          {
            "question": "Where did Oliver find the star?",
            "options": ["In the river", "On a tall tree", "On a fluffy purple cloud", "Under a rock"],
            "answer": "On a fluffy purple cloud"
          }
        ]
      }
    ]
    ''';

    final List<dynamic> data = jsonDecode(responseJson);
    final List<StoryBundle> bundles = data
        .map((item) => StoryBundle.fromJson(item as Map<String, dynamic>))
        .toList();

    // Pick a random story bundle from the pool
    final random = math.Random();
    return bundles[random.nextInt(bundles.length)];
  }
}
