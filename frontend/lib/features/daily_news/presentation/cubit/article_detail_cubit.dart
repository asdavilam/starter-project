import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/article.dart';

/// States for Article Detail features (AI Summary & TTS)
abstract class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object?> get props => [];
}

class ArticleDetailInitial extends ArticleDetailState {
  const ArticleDetailInitial();
}

class ArticleDetailLoadingSummary extends ArticleDetailState {
  const ArticleDetailLoadingSummary();
}

class ArticleDetailSummaryLoaded extends ArticleDetailState {
  final String summary;

  const ArticleDetailSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ArticleDetailSummaryError extends ArticleDetailState {
  final String message;

  const ArticleDetailSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Cubit for managing Article Detail AI features
class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GeminiService _geminiService;
  final TtsService _ttsService;

  ArticleDetailCubit({
    required GeminiService geminiService,
    required TtsService ttsService,
  })  : _geminiService = geminiService,
        _ttsService = ttsService,
        super(const ArticleDetailInitial());

  /// Generates AI summary for the article
  /// Uses URL as cache key to avoid regenerating
  Future<void> generateSummary(ArticleEntity article) async {
    if (article.content == null || article.content!.isEmpty) {
      emit(const ArticleDetailSummaryError(
        'No hay contenido disponible para resumir',
      ));
      return;
    }

    emit(const ArticleDetailLoadingSummary());

    try {
      final summary = await _geminiService.getArticleSummary(
        article.content!,
        cacheKey: article.url ?? article.title ?? '',
      );

      emit(ArticleDetailSummaryLoaded(summary));
    } catch (e) {
      // Extract user-friendly message from exception
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(ArticleDetailSummaryError(errorMessage));
    }
  }

  /// Reads the summary aloud using TTS
  Future<void> speakSummary(String text) async {
    try {
      await _ttsService.speak(text);
    } catch (e) {
      // TTS errors are non-critical, just log or ignore
    }
  }

  /// Stops TTS playback
  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  /// Cleanup when cubit is closed
  @override
  Future<void> close() async {
    await _ttsService.dispose();
    return super.close();
  }
}
