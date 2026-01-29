import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';

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
    final bloc = context.read<LocalArticleBloc>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ArticleDetailsView(article: article),
        ),
      ),
    );

    // Refresh saved articles after returning
    if (refreshOnReturn) {
      bloc.add(const GetSavedArticles());
    }
  }
}
