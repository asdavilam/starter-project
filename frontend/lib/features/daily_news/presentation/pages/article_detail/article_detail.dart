import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../injection_container.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // Custom Bottom Bar for Actions
        bottomNavigationBar: Builder(builder: (context) {
          return _buildBottomBar(context);
        }),
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            _buildArticleContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
        ),
      ),
      actions: [
        // AI Summary Button
        IconButton(
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          onPressed: () => _onShowAISummary(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        // TTS Button
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.white),
          onPressed: () => _onPlayAudio(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        // Reading Settings
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.text_fields, color: Colors.white),
          ),
          onSelected: (value) => _onReadingSettingSelected(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'font_size',
              child: Row(
                children: [
                  Icon(Icons.format_size),
                  SizedBox(width: 8),
                  Text('Tamaño de letra'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sepia',
              child: Row(
                children: [
                  Icon(Icons.chrome_reader_mode_outlined),
                  SizedBox(width: 8),
                  Text('Modo Sepia'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            article?.urlToImage != null
                ? CachedNetworkImage(
                    imageUrl: article!.urlToImage!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child:
                        const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
            // Gradient Overlay for Text Visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black45,
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Title in Flexible Space (Visible when expanded)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Text(
                article?.title ?? '',
                style: const TextStyle(
                  fontFamily: 'Butler',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  article?.publishedAt != null
                      ? DateTime.parse(article!.publishedAt!).toReadableDateTime
                      : '',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Spacer(),
                if (article?.author != null)
                  Chip(
                    label: Text(
                      article!.author!,
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Body Content
            Text(
              article?.content ?? 'No content available.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6, // Increased line height for readability
                    fontSize: 18,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Save Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _onSaveArticle(context),
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Guardar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Share Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onShareArticle(context),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Logic Placeholders (Clean Architecture) ---

  void _onSaveArticle(BuildContext context) {
    if (article != null) {
      context.read<LocalArticleBloc>().add(SaveArticle(article!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artículo guardado en marcadores'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onShareArticle(BuildContext context) {
    if (article?.url != null) {
      Share.share('Mira esta noticia: ${article!.title}\n${article!.url}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay enlace para compartir')),
      );
    }
  }

  void _onShowAISummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Resumen IA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '• Puntos clave del artículo generado por IA...\n'
                '• Análisis de sentimiento...\n'
                '• Contexto adicional...',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 24),
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
      },
    );
  }

  void _onPlayAudio(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reproduciendo versión de audio...')),
    );
  }

  void _onReadingSettingSelected(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ajuste seleccionado: $value')),
    );
  }
}
