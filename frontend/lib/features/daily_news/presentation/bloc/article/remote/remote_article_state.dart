import 'package:equatable/equatable.dart';

import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final String?
      error; // Changed from DioException to String for architectural cleanliness

  const RemoteArticlesState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading({List<ArticleEntity>? articles})
      : super(articles: articles);
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> article)
      : super(articles: article);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(String error, {List<ArticleEntity>? articles})
      : super(error: error, articles: articles);
}
