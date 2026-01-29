import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Gemini AI Service for generating article summaries
/// Implements caching to avoid repeated API calls
class GeminiService {
  late final GenerativeModel _model;
  final Map<String, String> _cache = {};

  GeminiService({required String apiKey}) {
    // Using gemini-2.5-flash-lite - current generation model (2026)
    // Lightweight and optimized for quick text summarization
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite', // Current supported model
      apiKey: apiKey,
    );
    debugPrint('✅ GeminiService initialized with model: gemini-2.5-flash-lite');
  }

  /// Generates a 3-point summary of the article content
  /// Returns cached result if available to save API calls
  Future<String> getArticleSummary(String content, {String? cacheKey}) async {
    // Use cache if available
    if (cacheKey != null && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final prompt = _buildSummaryPrompt(content);

    try {
      // usage of timeout to prevent UI blocking
      final response = await _model.generateContent(
          [Content.text(prompt)]).timeout(const Duration(seconds: 10));

      final summary = response.text ?? 'No se pudo generar el resumen';

      // Cache result
      if (cacheKey != null) {
        _cache[cacheKey] = summary;
      }

      debugPrint('✅ Summary generated successfully (${summary.length} chars)');
      return summary;
    } catch (e) {
      // Debug: Log actual error for development
      debugPrint('❌ Gemini API Error: $e');

      // User-friendly error message instead of technical details
      throw Exception(
        'Lo sentimos, no pudimos resumir la noticia en este momento. '
        'Por favor, intenta leer el texto completo abajo.',
      );
    }
  }

  String _buildSummaryPrompt(String content) {
    return '''
Actúa como un periodista experto. Resume el siguiente artículo de noticias en exactamente 3 puntos clave.

ARTÍCULO:
$content

INSTRUCCIONES:
- Genera 3 puntos concisos y claros
- Cada punto debe ser una oración completa
- Usa viñetas (•) para cada punto
- Mantén un tono profesional y objetivo
- Máximo 150 palabras en total

FORMATO DE SALIDA:
• [Punto clave 1]
• [Punto clave 2]
• [Punto clave 3]
''';
  }

  /// Clears the summary cache
  void clearCache() {
    _cache.clear();
  }

  /// Gets cache size for debugging/monitoring
  int get cacheSize => _cache.length;

  /// Translates the article content to the target language
  Future<String?> translateArticle(String text, String targetLanguage) async {
    final prompt =
        'Translate the following news article text to $targetLanguage. '
        'Maintain the professional tone and journalistic style. '
        'Do not add any introductory or concluding remarks, just the translation:\n\n$text';

    try {
      final content = [Content.text(prompt)];
      final response = await _model
          .generateContent(content)
          .timeout(const Duration(seconds: 10));
      return response.text;
    } catch (e) {
      debugPrint('❌ Gemini Translation Error: $e');
      if (e.toString().contains('429')) {
        throw Exception('Quota exceeded');
      }
      if (e.toString().contains('TimeoutException')) {
        throw Exception('El servicio tardó demasiado en responder.');
      }
      return null;
    }
  }
}
