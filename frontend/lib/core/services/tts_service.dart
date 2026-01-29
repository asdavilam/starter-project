import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for reading articles aloud
/// Configured for Spanish language by default
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Initializes TTS with Spanish configuration
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5); // Normal speed
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Configure callbacks
    _tts.setCompletionHandler(() {
      // Add logging or state updates if needed
    });

    _isInitialized = true;
  }

  /// Sets the TTS language (e.g., 'es-ES', 'en-US')
  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  /// Speaks the provided text
  /// Automatically initializes if not done yet
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (language != null) {
      await setLanguage(language);
    }

    await _tts.speak(text);
  }

  /// Stops TTS playback immediately
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Pauses TTS playback (can be resumed)
  Future<void> pause() async {
    await _tts.pause();
  }

  /// Gets available languages (for debugging)
  Future<List<dynamic>> getLanguages() async {
    return await _tts.getLanguages;
  }

  /// Gets available voices for current language
  Future<List<dynamic>> getVoices() async {
    return await _tts.getVoices;
  }

  /// Checks if TTS is currently speaking
  Future<bool> get isSpeaking async {
    final status = await _tts.awaitSpeakCompletion(false);
    return status == 1;
  }

  /// Sets speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Disposes TTS resources
  /// IMPORTANT: Call this in widget dispose to prevent memory leaks
  Future<void> dispose() async {
    await stop();
  }
}
