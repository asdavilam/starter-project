import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/article.dart';
import '../../cubit/article_detail_cubit.dart';
import '../../cubit/reading_settings_cubit.dart';
import 'widgets/ai_summary_bottom_sheet.dart';
import 'widgets/article_detail_app_bar.dart';
import 'widgets/article_detail_bottom_bar.dart';
import 'widgets/article_detail_content.dart';
import 'widgets/reading_settings_bottom_sheet.dart';

/// Article Details View - Refactored for modularity and performance
/// Uses extracted widgets for better maintainability
class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: ArticleDetailBottomBar(
        article: article,
        onShare: () => _onShareArticle(context),
      ),
      body: CustomScrollView(
        slivers: [
          ArticleDetailAppBar(
            article: article,
            onShowAISummary: () => _onShowAISummary(context),
            onPlayAudio: () => _onPlayAudio(context),
            onReadingSettingSelected: (value) =>
                _onReadingSettingSelected(context, value),
          ),
          ArticleDetailContent(article: article),
        ],
      ),
    );
  }

  // ============ Action Handlers ============

  void _onShareArticle(BuildContext context) {
    if (article?.url != null) {
      Share.share('Mira esta noticia: ${article!.title}\n${article!.url}');
    } else {
      _showSnackBar(context, 'No hay enlace para compartir');
    }
  }

  void _onShowAISummary(BuildContext context) {
    // Capture cubit reference BEFORE showing bottom sheet
    final cubit = context.read<ArticleDetailCubit>();

    // Trigger AI summary generation
    cubit.generateSummary(article!);

    // Show bottom sheet with the captured cubit
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.contentPadding),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const AISummaryBottomSheet(),
      ),
    );
  }

  void _onPlayAudio(BuildContext context) {
    if (article?.content != null && article!.content!.isNotEmpty) {
      context.read<ArticleDetailCubit>().speakSummary(article!.content!);
      _showSnackBar(context, 'Reproduciendo artículo...');
    } else {
      _showSnackBar(context, 'No hay contenido para reproducir');
    }
  }

  void _onReadingSettingSelected(BuildContext context, String value) {
    if (value == 'show_settings') {
      // Capture cubit before showing modal to avoid ProviderNotFoundException
      final readingSettingsCubit = context.read<ReadingSettingsCubit>();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => BlocProvider.value(
          value: readingSettingsCubit,
          child: const ReadingSettingsBottomSheet(),
        ),
      );
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
