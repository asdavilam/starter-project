import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/article.dart';
import '../../../../domain/entities/reading_settings.dart';
import '../../../cubit/reading_settings_cubit.dart';

/// Content section for Article Details
/// Displays metadata and article text with customizable reading settings
class ArticleDetailContent extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailContent({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingSettingsCubit, ReadingSettings>(
      builder: (context, settings) {
        // Update StatusBar based on theme mode
        _updateStatusBarStyle(settings.themeMode);

        return SliverToBoxAdapter(
          child: Container(
            color: _getBackgroundColor(settings.themeMode),
            padding: const EdgeInsets.all(AppConstants.contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetadata(settings),
                const SizedBox(height: AppConstants.spacing24),
                _buildBodyContent(context, settings),
                const SizedBox(height: AppConstants.spacing40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadata(ReadingSettings settings) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: AppConstants.iconSizeSmall,
          color: _getTextSecondaryColor(settings.themeMode),
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          article?.publishedAt != null
              ? DateTime.parse(article!.publishedAt!).toReadableDateTime
              : '',
          style: TextStyle(
            color: _getTextSecondaryColor(settings.themeMode),
            fontSize: AppConstants.metadataFontSize,
          ),
        ),
        const Spacer(),
        if (article?.author != null) _buildAuthorChip(settings),
      ],
    );
  }

  Widget _buildAuthorChip(ReadingSettings settings) {
    return Chip(
      label: Text(
        article!.author!,
        style: TextStyle(
          fontSize: AppConstants.chipFontSize,
          color: _getTextPrimaryColor(settings.themeMode),
        ),
      ),
      backgroundColor: _getChipBackgroundColor(settings.themeMode),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildBodyContent(BuildContext context, ReadingSettings settings) {
    // News API truncates content with "[+X chars]"
    // Prioritize description, then clean content
    String displayText = article?.description ??
        article?.content ??
        AppConstants.noContentMessage;

    // Remove truncation markers like "[+1234 chars]"
    displayText =
        displayText.replaceAll(RegExp(r'\[\+\d+\s*chars?\]'), '').trim();

    return Text(
      displayText,
      style: _getTextStyle(settings),
    );
  }

  /// Get text style based on reading settings
  TextStyle _getTextStyle(ReadingSettings settings) {
    // Base style with font size
    TextStyle textStyle = TextStyle(
      height: AppConstants.lineHeightExpanded,
      fontSize: settings.fontSize,
      color: _getTextPrimaryColor(settings.themeMode),
    );

    // Apply font family
    switch (settings.fontFamily) {
      case FontFamily.serif:
        return GoogleFonts.merriweather(
          textStyle: textStyle,
          fontWeight: FontWeight.w400,
        );
      case FontFamily.sansSerif:
        return GoogleFonts.inter(
          textStyle: textStyle,
          fontWeight: FontWeight.w400,
        );
    }
  }

  /// Get background color based on theme mode
  Color _getBackgroundColor(ReadingThemeMode mode) {
    switch (mode) {
      case ReadingThemeMode.dark:
        return const Color(0xFF1A1A1A);
      case ReadingThemeMode.sepia:
        return const Color(0xFFF4ECD8); // Warm sepia background
      case ReadingThemeMode.normal:
        return Colors.white;
    }
  }

  /// Get primary text color based on theme mode
  Color _getTextPrimaryColor(ReadingThemeMode mode) {
    switch (mode) {
      case ReadingThemeMode.dark:
        return Colors.white;
      case ReadingThemeMode.sepia:
        return const Color(0xFF5B4636); // Warm brown text
      case ReadingThemeMode.normal:
        return AppColors.textPrimary;
    }
  }

  /// Get secondary text color based on theme mode
  Color _getTextSecondaryColor(ReadingThemeMode mode) {
    switch (mode) {
      case ReadingThemeMode.dark:
        return Colors.white70;
      case ReadingThemeMode.sepia:
        return const Color(0xFF7A6A5A);
      case ReadingThemeMode.normal:
        return AppColors.textSecondary;
    }
  }

  /// Get chip background color based on theme mode
  Color _getChipBackgroundColor(ReadingThemeMode mode) {
    switch (mode) {
      case ReadingThemeMode.dark:
        return Colors.white12;
      case ReadingThemeMode.sepia:
        return const Color(0xFFE8DCC8);
      case ReadingThemeMode.normal:
        return Colors.grey[200]!;
    }
  }

  /// Update StatusBar style based on theme mode for better visibility
  void _updateStatusBarStyle(ReadingThemeMode mode) {
    switch (mode) {
      case ReadingThemeMode.dark:
        // Dark mode: light icons on dark background
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));
        break;
      case ReadingThemeMode.sepia:
        // Sepia mode: dark icons on warm background
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ));
        break;
      case ReadingThemeMode.normal:
        // Normal mode: dark icons on light background
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ));
        break;
    }
  }
}
