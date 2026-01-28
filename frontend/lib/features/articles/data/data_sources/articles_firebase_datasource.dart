import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/errors/server_exception.dart';
import '../models/article_model.dart';

/// DataSource de Firebase para Artículos
///
/// Responsable de todas las interacciones con Firebase (Firestore y Storage).
/// Lanza ServerException en caso de errores para que el repositorio los maneje.
/// Solo conoce modelos (ArticleModel), no entidades de dominio.
class ArticlesFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Nombre de la colección en Firestore
  static const String _articlesCollection = 'articles';

  /// Ruta base en Storage para imágenes de artículos
  static const String _articlesImagesPath = 'media/articles';

  ArticlesFirebaseDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  /// Obtiene todos los artículos publicados
  ///
  /// Filtra por isPublished == true y ordena por publishedAt descendente
  /// Retorna una lista de ArticleModel
  /// Lanza ServerException si ocurre un error
  Future<List<ArticleModel>> getArticles() async {
    try {
      final querySnapshot = await _firestore
          .collection(_articlesCollection)
          // .where('isPublished', isEqualTo: true) // Comentado para evitar error de índice compuesto
          .orderBy('publishedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al obtener artículos de Firestore: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Error desconocido al obtener artículos: $e',
      );
    }
  }

  /// Obtiene un artículo por su ID
  ///
  /// [id] - Identificador único del artículo
  /// Retorna un ArticleModel
  /// Lanza ServerException si no existe o hay error
  Future<ArticleModel> getArticleById(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_articlesCollection).doc(id).get();

      if (!docSnapshot.exists) {
        throw ServerException(
          message: 'Artículo no encontrado con ID: $id',
          code: 'not-found',
        );
      }

      return ArticleModel.fromFirestore(docSnapshot);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al obtener artículo de Firestore: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error desconocido al obtener artículo: $e',
      );
    }
  }

  Future<String> publishArticle(ArticleModel article) async {
    try {
      final data = article.toFirestore();
      final docRef = await _firestore.collection(_articlesCollection).add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al publicar artículo en Firestore: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Error desconocido al publicar artículo: $e',
      );
    }
  }

  // ... (omitted methods)

  Future<String> uploadArticleImage(File image) async {
    try {
      // Genera un nombre único para el archivo usando timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

      final storageRef = _storage.ref().child('$_articlesImagesPath/$fileName');

      String contentType = 'image/jpeg';
      if (image.path.endsWith('.png')) {
        contentType = 'image/png';
      } else if (image.path.endsWith('.jpg') || image.path.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      }

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'originalName': image.path.split('/').last,
        },
      );

      final uploadTask = storageRef.putFile(image, metadata);

      // Esperar completación o timeout
      await uploadTask.whenComplete(() {}).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw ServerException(
              message:
                  'Timeout (60s): Internet funciona pero Storage no responde. ¿Firewall?');
        },
      );

      // Obtiene la URL de descarga
      final downloadUrl = await uploadTask.snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al subir imagen a Storage: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Error desconocido al subir imagen: $e',
      );
    }
  }

  /// Actualiza un artículo existente
  ///
  /// [id] - ID del artículo a actualizar
  /// [article] - Datos actualizados del artículo
  /// Lanza ServerException si ocurre un error
  Future<void> updateArticle(String id, ArticleModel article) async {
    try {
      await _firestore
          .collection(_articlesCollection)
          .doc(id)
          .update(article.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al actualizar artículo en Firestore: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Error desconocido al actualizar artículo: $e',
      );
    }
  }

  /// Elimina un artículo de Firestore
  ///
  /// [id] - ID del artículo a eliminar
  /// Lanza ServerException si ocurre un error
  Future<void> deleteArticle(String id) async {
    try {
      await _firestore.collection(_articlesCollection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al eliminar artículo de Firestore: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Error desconocido al eliminar artículo: $e',
      );
    }
  }

  /// Elimina una imagen de Firebase Storage
  ///
  /// [imageUrl] - URL completa de la imagen a eliminar
  /// Lanza ServerException si ocurre un error
  Future<void> deleteArticleImage(String imageUrl) async {
    try {
      final storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Error al eliminar imagen de Storage: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'Error desconocido al eliminar imagen: $e',
      );
    }
  }
}
