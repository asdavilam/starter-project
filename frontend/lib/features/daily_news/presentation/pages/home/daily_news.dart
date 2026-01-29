import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/utils/article_category_helper.dart';
import '../../../../../core/utils/navigation_helper.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import '../../bloc/article/remote/remote_article_state.dart';
import '../../widgets/article_tile.dart';

/// Daily News Page - Refactored with constants and improved error handling
class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  String _selectedCategory = ArticleCategoryHelper.kAll;

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppConstants.titleFontSize,
          fontWeight: FontWeight.bold,
          fontFamily: AppConstants.primaryFontFamily,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () => _onNotificationsPressed(context),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.iconPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return BlocConsumer<RemoteArticlesBloc, RemoteArticlesState>(
      listener: (context, state) {
        if (state is RemoteArticlesError) {
          _showErrorSnackBar(context, state.error);
        }
      },
      builder: (context, state) {
        // Show articles if available
        if (state.articles != null && state.articles!.isNotEmpty) {
          return _buildArticlesPage(context, state.articles!);
        }

        // Show loading indicator
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }

        // Show error state
        if (state is RemoteArticlesError) {
          return _buildErrorState(context, state.error);
        }

        // Empty state
        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    // Apply local filtering based on selected category
    final filteredArticles = _filterArticles(articles);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RemoteArticlesBloc>().add(const GetArticles());
        },
        child: Column(
          children: [
            // Category Filter
            _buildCategoryFilter(),

            // Articles List
            Expanded(
              child: filteredArticles.isEmpty
                  ? _buildEmptyFilterState()
                  : ListView.builder(
                      itemCount: filteredArticles.length,
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.contentPadding,
                        left: 14,
                        right: 14,
                        top: 10,
                      ),
                      itemBuilder: (context, index) {
                        return ArticleWidget(
                          article: filteredArticles[index],
                          onArticlePressed: (article) =>
                              _onArticlePressed(context, article),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal scrollable list of category chips
  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: ArticleCategoryHelper.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = ArticleCategoryHelper.categories[index];
          final name = category['name'] as String;
          final emoji = category['emoji'] as String;
          final isSelected = _selectedCategory == name;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = name;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Filter articles locally
  List<ArticleEntity> _filterArticles(List<ArticleEntity> articles) {
    if (_selectedCategory == ArticleCategoryHelper.kAll) {
      return articles;
    }

    return articles.where((article) {
      final category = ArticleCategoryHelper.getCategory(article);
      return category == _selectedCategory;
    }).toList();
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay noticias en "$_selectedCategory"',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? error) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppConstants.iconSizeHuge,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              error ?? AppConstants.genericErrorMessage,
              style: const TextStyle(
                fontSize: AppConstants.bodyFontSize,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<RemoteArticlesBloc>().add(const GetArticles());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: AppConstants.iconSizeXXLarge,
              color: AppColors.iconDisabled,
            ),
            SizedBox(height: AppConstants.spacing16),
            Text(
              AppConstants.emptyStateMessage,
              style: TextStyle(
                fontFamily: AppConstants.primaryFontFamily,
                fontSize: AppConstants.bodyFontSize,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
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

  void _onNotificationsPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificaciones próximamente...')),
    );
  }

  void _showErrorSnackBar(BuildContext context, String? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ ${error ?? AppConstants.genericErrorMessage}'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
