import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/article.dart';

/// Content section for Article Details
/// Displays metadata and article text
class ArticleDetailContent extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailContent({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.contentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetadata(),
            const SizedBox(height: AppConstants.spacing24),
            _buildBodyContent(context),
            const SizedBox(height: AppConstants.spacing40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: AppConstants.iconSizeSmall,
          color: AppColors.iconSecondary,
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          article?.publishedAt != null
              ? DateTime.parse(article!.publishedAt!).toReadableDateTime
              : '',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppConstants.metadataFontSize,
          ),
        ),
        const Spacer(),
        if (article?.author != null) _buildAuthorChip(),
      ],
    );
  }

  Widget _buildAuthorChip() {
    return Chip(
      label: Text(
        article!.author!,
        style: const TextStyle(fontSize: AppConstants.chipFontSize),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    return Text(
      article?.content ?? AppConstants.noContentMessage,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: AppConstants.lineHeightExpanded,
            fontSize: AppConstants.bodyFontSize,
            color: AppColors.textPrimary,
          ),
    );
  }
}
