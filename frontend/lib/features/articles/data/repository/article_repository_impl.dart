import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/errors/server_exception.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repository/article_repository.dart';
import '../data_sources/articles_firebase_datasource.dart';
import '../models/article_model.dart';

/// Implementación del repositorio de artículos
///
/// Actúa como mediador entre el DataSource (capa de datos) y los UseCases (capa de dominio).
/// Responsabilidades:
/// - Llamar al ArticlesFirebaseDataSource
/// - Convertir ArticleModel a ArticleEntity
/// - Capturar ServerException y convertirlas en DataState
/// - Retornar siempre DataState<T> (nunca lanzar excepciones)
class ArticleRepositoryImpl implements ArticleRepository {
  final ArticlesFirebaseDataSource _firebaseDataSource;

  ArticleRepositoryImpl(this._firebaseDataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getArticles() async {
    try {
      // Llama al DataSource que retorna List<ArticleModel>
      final articleModels = await _firebaseDataSource.getArticles();

      // Convierte cada ArticleModel a ArticleEntity
      final articleEntities =
          articleModels.map((model) => model.toEntity()).toList();

      // Retorna éxito con las entidades
      return DataSuccess(articleEntities);
    } on ServerException catch (e) {
      // Captura ServerException y la convierte en DataFailed
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles'),
          message: e.message,
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      // Captura cualquier otro error inesperado
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles'),
          message: 'Error inesperado al obtener artículos: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getPublishedArticles() async {
    try {
      // El DataSource ya filtra por isPublished == true
      final articleModels = await _firebaseDataSource.getArticles();

      // Convierte a entidades
      final articleEntities =
          articleModels.map((model) => model.toEntity()).toList();

      return DataSuccess(articleEntities);
    } on ServerException catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles/published'),
          message: e.message,
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles/published'),
          message: 'Error inesperado al obtener artículos publicados: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<DataState<ArticleEntity>> getArticleById(String id) async {
    try {
      // Llama al DataSource que retorna ArticleModel
      final articleModel = await _firebaseDataSource.getArticleById(id);

      // Convierte a entidad
      final articleEntity = articleModel.toEntity();

      return DataSuccess(articleEntity);
    } on ServerException catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles/$id'),
          message: e.message,
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles/$id'),
          message: 'Error inesperado al obtener artículo: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<DataState<String>> uploadArticleImage(File image) async {
    try {
      // Llama al DataSource para subir la imagen
      final downloadUrl = await _firebaseDataSource.uploadArticleImage(image);

      // Retorna éxito con la URL de descarga
      return DataSuccess(downloadUrl);
    } on ServerException catch (e) {
      // Captura ServerException del DataSource
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'storage/articles/images'),
          message: e.message,
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      // Captura cualquier otro error inesperado
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'storage/articles/images'),
          message: 'Error inesperado al subir imagen: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<DataState<String>> createArticle(ArticleEntity article) async {
    try {
      // Convierte ArticleEntity a ArticleModel
      final articleModel = ArticleModel(
        id: article.id,
        author: article.author,
        title: article.title,
        description: article.description,
        content: article.content,
        url: article.url,
        thumbnailUrl: article.thumbnailUrl,
        publishedAt: article.publishedAt,
        isPublished: article.isPublished,
      );

      // Llama al DataSource para crear el artículo
      final articleId = await _firebaseDataSource.publishArticle(articleModel);

      // Retorna éxito con el ID del artículo creado
      return DataSuccess(articleId);
    } on ServerException catch (e) {
      // Captura ServerException del DataSource
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles'),
          message: e.message,
          type: DioExceptionType.unknown,
        ),
      );
    } catch (e) {
      // Captura cualquier otro error inesperado
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: 'articles'),
          message: 'Error inesperado al crear artículo: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}
