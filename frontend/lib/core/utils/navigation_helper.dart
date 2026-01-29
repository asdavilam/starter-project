import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import '../../features/daily_news/presentation/cubit/article_detail_cubit.dart';
import '../../features/daily_news/presentation/cubit/reading_settings_cubit.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../injection_container.dart';

/// Navigation helper to centralize common navigation patterns
/// and avoid code duplication across the app
class NavigationHelper {
  NavigationHelper._(); // Private constructor

  /// Navigates to Article Details while sharing the LocalArticleBloc instance
  /// This ensures the "Save" button state is synchronized across the app
  ///
  /// After returning from details, it refreshes the saved articles list
  static Future<void> navigateToArticleDetails({
    required BuildContext context,
    required ArticleEntity article,
    bool refreshOnReturn = true,
  }) async {
    final localBloc = context.read<LocalArticleBloc>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            // Provide LocalArticleBloc from parent context
            BlocProvider.value(value: localBloc),
            // Provide ArticleDetailCubit for AI & TTS
            BlocProvider(create: (_) => sl<ArticleDetailCubit>()),
            // Provide ReadingSettingsCubit for customization
            BlocProvider(create: (_) => sl<ReadingSettingsCubit>()),
          ],
          child: ArticleDetailsView(article: article),
        ),
      ),
    );

    // Refresh saved articles after returning
    if (refreshOnReturn) {
      localBloc.add(const GetSavedArticles());
    }
  }
}
