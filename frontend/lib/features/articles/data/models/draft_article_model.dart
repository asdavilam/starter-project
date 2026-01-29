import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

class DraftArticleModel extends ArticleEntity {
  const DraftArticleModel({
    super.id,
    required super.author,
    required super.title,
    required super.description,
    required super.content,
    super.url,
    required super.thumbnailUrl,
    required super.publishedAt,
    required super.isPublished,
  });

  factory DraftArticleModel.fromEntity(ArticleEntity entity) {
    return DraftArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      url: entity.url,
      thumbnailUrl: entity.thumbnailUrl,
      publishedAt: entity.publishedAt,
      isPublished: entity.isPublished,
    );
  }

  factory DraftArticleModel.fromJson(Map<String, dynamic> json) {
    return DraftArticleModel(
      id: json['id'],
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt']),
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'isPublished': isPublished,
    };
  }
}
