import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/article.dart';
import '../../../bloc/article/local/local_article_bloc.dart';
import '../../../bloc/article/local/local_article_event.dart';
import '../../../bloc/article/local/local_article_state.dart';

/// Bottom action bar for Article Details
/// Handles Save/Unsave and Share actions
class ArticleDetailBottomBar extends StatelessWidget {
  final ArticleEntity? article;
  final VoidCallback onShare;

  const ArticleDetailBottomBar({
    Key? key,
    required this.article,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        final isSaved = _checkIfSaved(state);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.bottomBarHorizontalPadding,
                vertical: AppConstants.bottomBarVerticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSaveButton(context, isSaved),
                  ),
                  const SizedBox(width: AppConstants.spacing16),
                  Expanded(
                    child: _buildShareButton(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _checkIfSaved(LocalArticlesState state) {
    if (state is LocalArticlesDone &&
        state.articles != null &&
        article != null) {
      return state.articles!
          .any((savedArticle) => _isSameArticle(savedArticle, article!));
    }
    return false;
  }

  /// Robust article comparison that handles null fields
  /// Prioritizes: ID > URL+Title > Title alone (as fallback)
  bool _isSameArticle(ArticleEntity saved, ArticleEntity current) {
    // 1. If both have IDs, compare by ID (most reliable for DB articles)
    if (saved.id != null && current.id != null) {
      return saved.id == current.id;
    }

    // 2. If both have URLs and they're not null, compare URL+Title
    if (saved.url != null && current.url != null && saved.url == current.url) {
      return true;
    }

    // 3. Fallback: Compare by title (less reliable but necessary for null URLs)
    // This prevents the null == null bug for custom articles
    if (saved.title != null && current.title != null) {
      return saved.title == current.title &&
          saved.author == current.author &&
          saved.publishedAt == current.publishedAt;
    }

    return false;
  }

  Widget _buildSaveButton(BuildContext context, bool isSaved) {
    return OutlinedButton.icon(
      onPressed: () => _onToggleSave(context, isSaved),
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
        color:
            isSaved ? AppColors.textOnPrimary : Theme.of(context).primaryColor,
      ),
      label: Text(
        isSaved ? 'Guardado' : 'Guardar',
        style: TextStyle(
          color: isSaved
              ? AppColors.textOnPrimary
              : Theme.of(context).primaryColor,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSaved ? AppColors.primary : Colors.transparent,
        padding: const EdgeInsets.symmetric(
            vertical: AppConstants.contentPaddingSmall),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: onShare,
      icon: const Icon(Icons.share, color: AppColors.iconOnPrimary),
      label: const Text('Compartir'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
            vertical: AppConstants.contentPaddingSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
      ),
    );
  }

  void _onToggleSave(BuildContext context, bool isSaved) {
    if (article == null) return;

    if (isSaved) {
      _handleRemove(context);
    } else {
      _handleSave(context);
    }
  }

  void _handleRemove(BuildContext context) {
    final state = context.read<LocalArticleBloc>().state;
    if (state is LocalArticlesDone &&
        state.articles != null &&
        article != null) {
      try {
        final savedArticle = state.articles!
            .firstWhere((element) => _isSameArticle(element, article!));
        context.read<LocalArticleBloc>().add(RemoveArticle(savedArticle));
        _showSnackBar(
          context,
          AppConstants.articleRemovedMessage,
          isError: false,
        );
      } catch (e) {
        _showSnackBar(
          context,
          AppConstants.articleNotFoundMessage,
          isError: true,
        );
      }
    }
  }

  void _handleSave(BuildContext context) {
    context.read<LocalArticleBloc>().add(SaveArticle(article!));
    _showSnackBar(
      context,
      AppConstants.articleSavedMessage,
      isError: false,
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.warning : null,
      ),
    );
  }
}
