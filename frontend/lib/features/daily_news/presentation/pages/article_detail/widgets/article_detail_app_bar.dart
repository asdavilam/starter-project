import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/article.dart';

/// Modular SliverAppBar component for Article Details
/// Extracted for better maintainability and testability
class ArticleDetailAppBar extends StatelessWidget {
  final ArticleEntity? article;
  final VoidCallback onShowAISummary;
  final VoidCallback onPlayAudio;
  final ValueChanged<String> onReadingSettingSelected;

  const ArticleDetailAppBar({
    Key? key,
    required this.article,
    required this.onShowAISummary,
    required this.onPlayAudio,
    required this.onReadingSettingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: AppConstants.articleDetailExpandedHeight,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: AppConstants.elevationNone,
      leading: _buildBackButton(context),
      actions: _buildActions(context),
      flexibleSpace: _buildFlexibleSpace(),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon:
          const Icon(Icons.arrow_back_ios_new, color: AppColors.iconOnPrimary),
      onPressed: () => Navigator.pop(context),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.overlay,
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      // AI Summary Button
      IconButton(
        icon: const Icon(Icons.auto_awesome, color: AppColors.iconOnPrimary),
        onPressed: onShowAISummary,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.overlay,
        ),
      ),
      // TTS Button
      IconButton(
        icon: const Icon(Icons.volume_up, color: AppColors.iconOnPrimary),
        onPressed: onPlayAudio,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.overlay,
        ),
      ),
      // Reading Settings
      _buildReadingSettingsMenu(context),
    ];
  }

  Widget _buildReadingSettingsMenu(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.tune, color: AppColors.iconOnPrimary),
      onPressed: () => onReadingSettingSelected('show_settings'),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.overlay,
      ),
    );
  }

  Widget _buildFlexibleSpace() {
    return FlexibleSpaceBar(
      stretchModes: const [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
      ],
      background: Stack(
        fit: StackFit.expand,
        children: [
          _buildHeroImage(),
          _buildGradientOverlay(),
          _buildTitle(),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return article?.urlToImage != null
        ? CachedNetworkImage(
            imageUrl: article!.urlToImage!,
            fit: BoxFit.cover,
          )
        : Container(
            color: AppColors.surfaceBackground,
            child: const Icon(
              Icons.image,
              size: AppConstants.iconSizeXLarge,
              color: AppColors.iconDisabled,
            ),
          );
  }

  Widget _buildGradientOverlay() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.heroGradient,
          stops: AppColors.heroGradientStops,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      bottom: AppConstants.contentPadding,
      left: AppConstants.contentPadding,
      right: AppConstants.contentPadding,
      child: Text(
        article?.title ?? '',
        style: const TextStyle(
          fontFamily: AppConstants.primaryFontFamily,
          fontSize: AppConstants.titleFontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnPrimary,
          height: AppConstants.lineHeightCompact,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
