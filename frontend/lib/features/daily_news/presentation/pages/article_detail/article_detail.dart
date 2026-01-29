import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/reading_settings.dart';
import '../../cubit/article_detail_cubit.dart';
import '../../cubit/reading_settings_cubit.dart';
import '../../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../../subscription/presentation/widgets/premium_bottom_sheet.dart';
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
    return BlocListener<ArticleDetailCubit, ArticleDetailState>(
      listener: (context, state) {
        if (state is ArticleDetailQuotaExceeded) {
          _showPaywall(context);
        } else if (state is ArticleDetailTranslationLoaded) {
          // Decrement quota when translation is successful
          context.read<SubscriptionCubit>().decrementQuota();
          _showTranslationDialog(context, state.translation, state.language);
        } else if (state is ArticleDetailSummaryLoaded) {
          // Decrement quota when summary is successful
          context.read<SubscriptionCubit>().decrementQuota();
          // Note: Summary UI is shown via "onShowAISummary" which opens bottom sheet
          // listening to the same cubit.
        } else if (state is ArticleDetailSummaryError) {
          _showSnackBar(context, state.message);
        }
      },
      child: BlocBuilder<ReadingSettingsCubit, ReadingSettings>(
        builder: (context, settings) {
          // Determine background color based on reading mode
          Color backgroundColor = Colors.white; // Default
          switch (settings.themeMode) {
            case ReadingThemeMode.dark:
              backgroundColor = const Color(0xFF1A1A1A);
              break;
            case ReadingThemeMode.sepia:
              backgroundColor = const Color(0xFFF4ECD8);
              break;
            case ReadingThemeMode.normal:
              backgroundColor = Colors.white;
              break;
          }

          return Scaffold(
            backgroundColor: backgroundColor,
            bottomNavigationBar: ArticleDetailBottomBar(
              article: article,
              onShare: () => _onShareArticle(context),
              backgroundColor: backgroundColor,
            ),
            body: CustomScrollView(
              slivers: [
                BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
                  builder: (context, state) {
                    return ArticleDetailAppBar(
                      article: article,
                      onShowAISummary: () => _onShowAISummary(context),
                      onPlayAudio: () => _onPlayAudio(context),
                      isPlaying: state is ArticleDetailAudioPlaying,
                      onTranslate: () => _onTranslatePressed(context),
                      onReadingSettingSelected: (value) =>
                          _onReadingSettingSelected(context, value),
                      backgroundColor: backgroundColor,
                    );
                  },
                ),
                ArticleDetailContent(article: article),
              ],
            ),
          );
        },
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

  void _onTranslatePressed(BuildContext context) {
    // Show language selection dialog
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppConstants.chooseLanguageTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...AppConstants.supportedTranslationLanguages.entries.map((entry) {
              final parts = entry.value.split(' ');
              final flag = parts[0];
              final name = parts.sublist(1).join(' ');

              return ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 24)),
                title: Text(name),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ArticleDetailCubit>()
                      .translateArticle(article!, entry.key);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    final subscriptionCubit = context.read<SubscriptionCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumBottomSheet(
        onUpgrade: () {
          subscriptionCubit.upgradeToPro();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 ¡Bienvenido a Pro! Disfruta sin límites.'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showTranslationDialog(
      BuildContext context, String translation, String language) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Traducción ($language)',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    translation,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    // Check current state
    final cubit = context.read<ArticleDetailCubit>();
    if (cubit.state is ArticleDetailAudioPlaying) {
      cubit.stopSpeaking();
      return;
    }

    // Robust text selection for audio: Content -> Description -> Empty
    final textToSpeak = (article?.content?.isNotEmpty == true)
        ? article!.content!
        : (article?.description?.isNotEmpty == true)
            ? article!.description!
            : '';

    if (textToSpeak.isEmpty) {
      _showSnackBar(context, 'No hay contenido para reproducir');
      return;
    }

    // Show language selection
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppConstants.listenToNewsTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...AppConstants.supportedTTSLanguages.entries.map((entry) {
              final parts = entry.value.split(' ');
              final flag = parts[0];
              final name = parts.sublist(1).join(' ');

              return ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 24)),
                title: Text(name),
                onTap: () {
                  Navigator.pop(context);
                  cubit.speakArticle(textToSpeak, language: entry.key);
                  final msg = entry.key == 'Spanish'
                      ? AppConstants.playingInSpanish
                      : AppConstants.playingInEnglish;
                  _showSnackBar(context, msg);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
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
