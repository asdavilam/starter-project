import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/navigation_helper.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../widgets/article_tile.dart';

/// Saved Articles Page - Refactored with constants and improved UX
class SavedArticles extends HookWidget {
  const SavedArticles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Artículos Guardados',
        style: TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
      elevation: AppConstants.elevationNone,
      centerTitle: false,
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LocalArticlesDone) {
          return _buildArticlesList(state.articles!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildArticlesList(List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: articles.length,
      padding:
          const EdgeInsets.symmetric(vertical: AppConstants.contentPadding),
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: articles[index],
          isRemovable: true,
          onRemove: (article) => _onRemoveArticle(context, article),
          onArticlePressed: (article) => _onArticlePressed(context, article),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: AppConstants.iconSizeXXLarge,
            color: AppColors.iconDisabled,
          ),
          SizedBox(height: AppConstants.spacing16),
          Text(
            AppConstants.savedArticlesEmptyMessage,
            style: TextStyle(
              fontFamily: AppConstants.primaryFontFamily,
              fontSize: AppConstants.bodyFontSize,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.articleRemovedMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    NavigationHelper.navigateToArticleDetails(
      context: context,
      article: article,
      refreshOnReturn: true,
    );
  }
}
