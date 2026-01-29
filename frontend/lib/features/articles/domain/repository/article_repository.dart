import 'dart:io';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

/// Interfaz del repositorio de artículos
///
/// Define el contrato para las operaciones de artículos.
/// Esta es una abstracción pura - sin implementaciones concretas.
/// La implementación real estará en la capa de datos (ArticleRepositoryImpl).
abstract class ArticleRepository {
  /// Obtiene todos los artículos
  ///
  /// Retorna una lista de todos los artículos disponibles,
  /// independientemente de su estado de publicación.
  Future<DataState<List<ArticleEntity>>> getArticles();

  /// Obtiene solo los artículos publicados
  ///
  /// Retorna una lista filtrada de artículos donde isPublished == true.
  Future<DataState<List<ArticleEntity>>> getPublishedArticles();

  /// Obtiene un artículo específico por su ID
  ///
  /// [id] - Identificador único del artículo
  ///
  /// Retorna el artículo solicitado o un error si no existe.
  Future<DataState<ArticleEntity>> getArticleById(String id);

  /// Sube una imagen de artículo a Firebase Storage
  ///
  /// [image] - Archivo de imagen a subir
  ///
  /// Retorna la URL de descarga pública de la imagen en caso de éxito.
  Future<DataState<String>> uploadArticleImage(File image);

  /// Crea un nuevo artículo en Firestore
  ///
  /// [article] - El artículo a crear (debe incluir thumbnailUrl)
  ///
  /// Retorna el ID del artículo creado en caso de éxito.
  Future<DataState<String>> createArticle(ArticleEntity article);

  /// Guarda un borrador localmente
  Future<DataState<ArticleEntity>> saveDraft(ArticleEntity article);

  /// Obtiene todos los borradores locales
  Future<DataState<List<ArticleEntity>>> getDrafts();

  /// Elimina un borrador local por ID
  Future<DataState<void>> deleteDraft(String id);

  /// Elimina un artículo remoto por ID
  Future<DataState<void>> deleteArticle(String id);

  /// Actualiza un artículo remoto
  Future<DataState<void>> updateArticle(ArticleEntity article);
}
