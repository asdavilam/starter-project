import 'package:equatable/equatable.dart';

import '../../domain/entities/article_entity.dart';

/// Estados del RemoteArticlesBloc
///
/// Define todos los posibles estados durante la obtención de artículos remotos
abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final String? error;

  const RemoteArticlesState({
    this.articles,
    this.error,
  });

  @override
  List<Object?> get props => [articles, error];
}

/// Estado inicial y de carga
///
/// Indica que el bloc está procesando la solicitud de artículos
/// Estado inicial y de carga
///
/// Indica que el bloc está procesando la solicitud de artículos
class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading({List<ArticleEntity>? articles})
      : super(articles: articles);
}

/// Estado exitoso
///
/// Indica que los artículos se obtuvieron correctamente
/// Contiene la lista de artículos obtenidos
class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

/// Estado de error
///
/// Indica que ocurrió un error al obtener los artículos
/// Contiene el mensaje de error
class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(String error, {List<ArticleEntity>? articles})
      : super(error: error, articles: articles);
}
