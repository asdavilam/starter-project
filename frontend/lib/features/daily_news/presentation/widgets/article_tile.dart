import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatefulWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  }) : super(key: key);

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(context),
                const SizedBox(width: 16),
                _buildTitleAndMetadata(),
                _buildRemovableArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        width: 100, // Fixed width for consistency
        height: 100, // Fixed height for consistency (squircle feeling)
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.08),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.article?.urlToImage ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CupertinoActivityIndicator(),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEEEEEE), Colors.white],
              ),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndMetadata() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.article?.title ?? '',
            maxLines: 4, // Increased to 4 as requested
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Metadata: Date + Read Time
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${_parseDate(widget.article!.publishedAt)} • 4 min de lectura',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (widget.isRemovable == true) {
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _parseDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return date.timeAgo;
    } catch (e) {
      return '';
    }
  }

  void _onTap() {
    if (widget.onArticlePressed != null) {
      widget.onArticlePressed!(widget.article!);
    }
  }

  void _onRemove() {
    if (widget.onRemove != null) {
      widget.onRemove!(widget.article!);
    }
  }
}
