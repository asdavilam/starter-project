import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../subscription/domain/repositories/subscription_repository.dart';
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

class ArticleDetailLoadingTranslation extends ArticleDetailState {
  const ArticleDetailLoadingTranslation();
}

class ArticleDetailSummaryLoaded extends ArticleDetailState {
  final String summary;

  const ArticleDetailSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ArticleDetailTranslationLoaded extends ArticleDetailState {
  final String translation;
  final String language;

  const ArticleDetailTranslationLoaded(this.translation, this.language);

  @override
  List<Object?> get props => [translation, language];
}

class ArticleDetailSummaryError extends ArticleDetailState {
  final String message;

  const ArticleDetailSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}

class ArticleDetailQuotaExceeded extends ArticleDetailState {
  const ArticleDetailQuotaExceeded();
}

class ArticleDetailAudioPlaying extends ArticleDetailState {
  final String summary;
  const ArticleDetailAudioPlaying(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ArticleDetailAudioStopped extends ArticleDetailState {
  const ArticleDetailAudioStopped();
}

/// Cubit for managing Article Detail AI features
class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GeminiService _geminiService;
  final TtsService _ttsService;
  final SubscriptionRepository _subscriptionRepository;

  ArticleDetailCubit({
    required GeminiService geminiService,
    required TtsService ttsService,
    required SubscriptionRepository subscriptionRepository,
  })  : _geminiService = geminiService,
        _ttsService = ttsService,
        _subscriptionRepository = subscriptionRepository,
        super(const ArticleDetailInitial());

  /// Generates AI summary for the article
  Future<void> generateSummary(ArticleEntity article) async {
    if (!_canUseAiFeature()) {
      emit(const ArticleDetailQuotaExceeded());
      return;
    }

    // Use content if available, otherwise fallback to description
    final textToProcess = (article.content?.isNotEmpty == true)
        ? article.content!
        : article.description;

    if (textToProcess == null || textToProcess.isEmpty) {
      emit(const ArticleDetailSummaryError(
        'No hay contenido disponible para resumir',
      ));
      return;
    }

    emit(const ArticleDetailLoadingSummary());

    try {
      final summary = await _geminiService.getArticleSummary(
        textToProcess,
        cacheKey: article.url ?? article.title ?? '',
      );

      // Note: Quota decrement is handled by the UI listener calling SubscriptionCubit
      // to ensure global state state synchronization.

      emit(ArticleDetailSummaryLoaded(summary));
    } catch (e) {
      _handleError(e);
    }
  }

  /// Translates article to target language
  Future<void> translateArticle(ArticleEntity article, String language) async {
    if (!_canUseAiFeature()) {
      emit(const ArticleDetailQuotaExceeded());
      return;
    }

    // Use content if available, otherwise fallback to description
    final textToProcess = (article.content?.isNotEmpty == true)
        ? article.content!
        : article.description;

    if (textToProcess == null || textToProcess.isEmpty) {
      emit(const ArticleDetailSummaryError('No hay contenido para traducir'));
      return;
    }

    emit(const ArticleDetailLoadingTranslation());

    try {
      final translation = await _geminiService.translateArticle(
        textToProcess,
        language,
      );

      if (translation != null) {
        // Quota decrement is handled by UI listener
        emit(ArticleDetailTranslationLoaded(translation, language));
      } else {
        emit(
            const ArticleDetailSummaryError('No se pudo traducir el artículo'));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  bool _canUseAiFeature() {
    return _subscriptionRepository.isProUser ||
        _subscriptionRepository.remainingFreeRequests > 0;
  }

  void _handleError(Object e) {
    if (e.toString().contains('Quota exceeded')) {
      emit(const ArticleDetailQuotaExceeded());
    } else {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(ArticleDetailSummaryError(errorMessage));
    }
  }

  /// Reads the article aloud using TTS
  Future<void> speakArticle(String text, {String? language}) async {
    try {
      emit(ArticleDetailAudioPlaying(text));
      // Default to Spanish (es-ES) if not specified or "Spanish" selected
      // Map friendly names to locale codes
      String locale = 'es-ES';
      if (language == 'English') locale = 'en-US';

      await _ttsService.speak(text, language: locale);
    } catch (e) {
      // TTS errors are non-critical, but we should reset state
      emit(const ArticleDetailAudioStopped());
    }
  }

  /// Stops TTS playback
  Future<void> stopSpeaking() async {
    await _ttsService.stop();

    // Check if we have the summmary in the current state to restore it
    if (state is ArticleDetailAudioPlaying) {
      final currentSummary = (state as ArticleDetailAudioPlaying).summary;
      emit(ArticleDetailSummaryLoaded(currentSummary));
    } else {
      emit(const ArticleDetailAudioStopped());
    }
  }

  /// Cleanup when cubit is closed
  @override
  Future<void> close() async {
    await _ttsService.dispose();
    return super.close();
  }
}
