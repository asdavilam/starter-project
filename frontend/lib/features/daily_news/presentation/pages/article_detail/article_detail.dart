import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../domain/entities/article.dart';
import 'widgets/article_detail_app_bar.dart';
import 'widgets/article_detail_bottom_bar.dart';
import 'widgets/article_detail_content.dart';

/// Article Details View - Refactored for modularity and performance
/// Uses extracted widgets for better maintainability
class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: ArticleDetailBottomBar(
        article: article,
        onShare: () => _onShareArticle(context),
      ),
      body: CustomScrollView(
        slivers: [
          ArticleDetailAppBar(
            article: article,
            onShowAISummary: () => _onShowAISummary(context),
            onPlayAudio: () => _onPlayAudio(context),
            onReadingSettingSelected: (value) =>
                _onReadingSettingSelected(context, value),
          ),
          ArticleDetailContent(article: article),
        ],
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

  void _onShowAISummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.contentPadding),
        ),
      ),
      builder: (context) => _buildAISummarySheet(context),
    );
  }

  Widget _buildAISummarySheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.contentPaddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accent),
              const SizedBox(width: AppConstants.spacing8),
              Text(
                'Resumen IA',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),
          const Text(
            '• Puntos clave del artículo generado por IA...\n'
            '• Análisis de sentimiento...\n'
            '• Contexto adicional...',
            style: TextStyle(height: AppConstants.lineHeightNormal),
          ),
          const SizedBox(height: AppConstants.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }

  void _onPlayAudio(BuildContext context) {
    _showSnackBar(context, 'Reproduciendo versión de audio...');
  }

  void _onReadingSettingSelected(BuildContext context, String value) {
    _showSnackBar(context, 'Ajuste seleccionado: $value');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
