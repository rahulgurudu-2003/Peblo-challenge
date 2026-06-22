import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    // Slower speech rate so children can follow along easily
    await _flutterTts.setSpeechRate(0.38); 
    // Higher pitch makes the TTS sound high-pitched, friendly, and child-like (1.35)
    await _flutterTts.setPitch(1.35); 
    await _flutterTts.setVolume(1.0);

    try {
      // 1. Try to set language to Indian English by default
      await _flutterTts.setLanguage("en-IN");
      
      // 2. Query available native system voices on the user's phone to find a child-friendly voice
      dynamic voices = await _flutterTts.getVoices;
      if (voices is List) {
        Map? chosenVoice;
        for (var voice in voices) {
          if (voice is Map) {
            String name = (voice['name'] ?? '').toString().toLowerCase();
            String locale = (voice['locale'] ?? '').toString().toLowerCase();
            
            // Focus on English voices
            if (locale.startsWith("en")) {
              // Try to find child, kid, female, or high-fidelity network voices
              if (name.contains("child") || name.contains("kid") || name.contains("female") || name.contains("network")) {
                chosenVoice = voice;
                // If it explicitly has "child" or "kid" in its name, use it immediately
                if (name.contains("child") || name.contains("kid")) {
                  break;
                }
              }
            }
          }
        }
        
        if (chosenVoice != null) {
          await _flutterTts.setVoice({
            "name": chosenVoice["name"],
            "locale": chosenVoice["locale"],
          });
        }
      }
    } catch (e) {
      // Fallback gracefully if custom voice query is not supported on the device
    }
  }

  // Set callback listeners for state changes
  void setStartHandler(Function() onStart) {
    _flutterTts.setStartHandler(() {
      onStart();
    });
  }

  void setCompletionHandler(Function() onComplete) {
    _flutterTts.setCompletionHandler(() {
      onComplete();
    });
  }

  void setErrorHandler(Function(String message) onError) {
    _flutterTts.setErrorHandler((msg) {
      onError(msg.toString());
    });
  }

  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception("TTS Engine failed to speak: $e");
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
