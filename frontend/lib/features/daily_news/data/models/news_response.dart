import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class NewsResponse {
  final String? status;
  final int? totalResults;
  final List<ArticleModel>? articles;

  NewsResponse({
    this.status,
    this.totalResults,
    this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] as String?,
      totalResults: json['totalResults'] as int?,
      articles: (json['articles'] as List<dynamic>?)
          ?.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
