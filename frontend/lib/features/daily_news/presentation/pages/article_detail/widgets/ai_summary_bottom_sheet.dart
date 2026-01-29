import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../cubit/article_detail_cubit.dart';

/// Bottom sheet displaying AI-generated article summary
class AISummaryBottomSheet extends StatelessWidget {
  const AISummaryBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.contentPaddingLarge),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.contentPadding),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppConstants.spacing24),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacing8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.spacing8),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.accent,
            size: AppConstants.iconSizeMedium,
          ),
        ),
        const SizedBox(width: AppConstants.spacing12),
        Expanded(
          child: Text(
            'Resumen con IA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.primaryFontFamily,
                ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<ArticleDetailCubit, ArticleDetailState>(
      builder: (context, state) {
        if (state is ArticleDetailLoadingSummary) {
          return _buildLoadingState();
        } else if (state is ArticleDetailSummaryLoaded) {
          return _buildSummaryState(context, state.summary, isPlaying: false);
        } else if (state is ArticleDetailAudioPlaying) {
          return _buildSummaryState(context, state.summary, isPlaying: true);
        } else if (state is ArticleDetailSummaryError) {
          return _buildErrorState(context, state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        SizedBox(height: AppConstants.spacing16),
        CircularProgressIndicator(),
        SizedBox(height: AppConstants.spacing24),
        Text(
          'Generando resumen inteligente...',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: AppConstants.bodyFontSize,
          ),
        ),
        SizedBox(height: AppConstants.spacing16),
        Text(
          'Analizando contenido del artículo...',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppConstants.bodySmallFontSize,
          ),
        ),
        SizedBox(height: AppConstants.spacing40),
      ],
    );
  }

  Widget _buildSummaryState(BuildContext context, String summary,
      {required bool isPlaying}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.contentPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppConstants.spacing12),
          ),
          child: Text(
            summary,
            style: const TextStyle(
              fontSize: AppConstants.bodyFontSize,
              height: AppConstants.lineHeightExpanded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (isPlaying) {
                context.read<ArticleDetailCubit>().stopSpeaking();
              } else {
                context.read<ArticleDetailCubit>().speakArticle(summary);
              }
            },
            icon: Icon(isPlaying
                ? Icons.stop_circle_outlined
                : Icons.volume_up_outlined),
            label: Text(isPlaying ? 'Detener lectura' : 'Escuchar resumen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPlaying ? AppColors.error : AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.contentPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.buttonBorderRadius,
                ),
              ),
              elevation: isPlaying ? 0 : 2,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: AppConstants.iconSizeXLarge,
          color: AppColors.error,
        ),
        const SizedBox(height: AppConstants.spacing16),
        Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppConstants.bodyFontSize,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing40),
      ],
    );
  }
}
