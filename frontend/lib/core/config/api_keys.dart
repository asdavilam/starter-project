import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Keys Configuration
/// Keys are loaded from .env file which is excluded from version control
///
/// Setup instructions:
/// 1. Copy .env.example to .env
/// 2. Fill in your actual API keys
/// 3. Never commit .env to git (it's in .gitignore)

class ApiKeys {
  // Gemini AI API Key
  // Loaded from .env file: GEMINI_API_KEY=your_key_here
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found in .env file. '
        'Make sure you have created .env from .env.example',
      );
    }
    return key;
  }

  // Add other API keys here as needed
  // static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';
}
