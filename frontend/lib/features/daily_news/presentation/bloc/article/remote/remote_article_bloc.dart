import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart'
    as new_article;
import 'package:news_app_clean_architecture/features/articles/domain/use_cases/get_published_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart'
    as legacy_article;
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(
    this._getPublishedArticlesUseCase,
    this._getArticleUseCase,
  ) : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    // 0. Conservar datos actuales al cargar (para evitar pantalla blanca en refresh)
    final currentArticles = state.articles;
    emit(RemoteArticlesLoading(articles: currentArticles));

    // Consultar ambas fuentes en paralelo
    final results = await Future.wait([
      _getPublishedArticlesUseCase(), // Firebase
      _getArticleUseCase(), // API
    ]);

    final firebaseResult =
        results[0] as DataState<List<new_article.ArticleEntity>>;
    final apiResult =
        results[1] as DataState<List<legacy_article.ArticleEntity>>;

    List<legacy_article.ArticleEntity> combinedArticles = [];

    // 1. Agregar noticias de API (si hubo éxito)
    if (apiResult is DataSuccess && apiResult.data != null) {
      combinedArticles.addAll(apiResult.data!);
    }

    // 2. Agregar noticias de Firebase (si hubo éxito)
    if (firebaseResult is DataSuccess && firebaseResult.data != null) {
      final mappedFirebaseArticles = firebaseResult.data!
          .map((newArticle) => _mapToLegacy(newArticle))
          .toList();
      combinedArticles.addAll(mappedFirebaseArticles);
    }

    // 3. Emitir resultado combinado o error si ambos fallaron
    if (combinedArticles.isNotEmpty) {
      // Ordenar por fecha (descendente) - Asumiendo formato String ISO8601
      combinedArticles.sort((a, b) {
        final dateA = DateTime.tryParse(a.publishedAt ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b.publishedAt ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA); // Descendente (más nuevo primero)
      });

      emit(RemoteArticlesDone(combinedArticles));
    } else {
      // Si ambas fallaron, conservamos los datos viejos si existen y emitimos error
      final errorMsg = apiResult.error?.message ??
          firebaseResult.error?.message ??
          'Error desconocido al actualizar';

      emit(RemoteArticlesError(errorMsg, articles: currentArticles));
    }
  }

  legacy_article.ArticleEntity _mapToLegacy(new_article.ArticleEntity article) {
    return legacy_article.ArticleEntity(
      // Usamos hashCode como ID temporal int, ya que Firebase usa String
      id: article.id?.hashCode,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: article.thumbnailUrl,
      publishedAt: article.publishedAt.toIso8601String(),
      content: article.content,
    );
  }
}
