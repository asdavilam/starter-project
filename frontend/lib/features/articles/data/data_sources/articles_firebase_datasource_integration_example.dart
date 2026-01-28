/// Ejemplo de integración de ArticlesFirebaseDataSource
///
/// Este archivo muestra cómo usar ArticlesFirebaseDataSource
/// y cómo debe ser integrado en el repositorio

/*

ESTRUCTURA DE LA CAPA DE DATOS COMPLETADA
==========================================

core/errors/
  └── server_exception.dart         ✅ Excepción personalizada para errores de servidor

features/articles/data/
  ├── models/
  │   └── article_model.dart        ✅ Modelo con serialización Firestore
  └── data_sources/
      └── articles_firebase_datasource.dart  ✅ DataSource con Firebase


MÉTODOS IMPLEMENTADOS EN ArticlesFirebaseDataSource
====================================================

1. getArticles()
   - Filtra por isPublished == true
   - Ordena por publishedAt descendente
   - Retorna List<ArticleModel>
   - Lanza ServerException en error

2. getArticleById(String id)
   - Obtiene un artículo específico
   - Retorna ArticleModel
   - Lanza ServerException si no existe

3. publishArticle(ArticleModel article)
   - Crea un nuevo documento en Firestore
   - Retorna el ID del documento creado
   - Lanza ServerException en error

4. updateArticle(String id, ArticleModel article)
   - Actualiza un artículo existente
   - Lanza ServerException en error

5. deleteArticle(String id)
   - Elimina un artículo de Firestore
   - Lanza ServerException en error

6. uploadArticleImage(File image)
   - Sube imagen a Firebase Storage
   - Retorna la URL de descarga pública
   - Genera nombre único con timestamp
   - Lanza ServerException en error

7. deleteArticleImage(String imageUrl)
   - Elimina imagen de Storage
   - Lanza ServerException en error


EJEMPLO DE USO EN REPOSITORIO (ArticleRepositoryImpl)
======================================================

import 'package:news_app_clean_architecture/core/errors/server_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import '../data_sources/articles_firebase_datasource.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticlesFirebaseDataSource _firebaseDataSource;

  ArticleRepositoryImpl(this._firebaseDataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getArticles() async {
    try {
      // El DataSource retorna ArticleModel, convertimos a Entity
      final models = await _firebaseDataSource.getArticles();
      final entities = models.map((model) => model.toEntity()).toList();
      
      return DataSuccess(entities);
    } on ServerException catch (e) {
      // Capturamos ServerException y la convertimos en DataState.error
      return DataFailed(DioError(
        requestOptions: RequestOptions(path: ''),
        message: e.message,
      ));
    }
  }

  @override
  Future<DataState<ArticleEntity>> getArticleById(String id) async {
    try {
      final model = await _firebaseDataSource.getArticleById(id);
      return DataSuccess(model.toEntity());
    } on ServerException catch (e) {
      return DataFailed(DioError(
        requestOptions: RequestOptions(path: ''),
        message: e.message,
      ));
    }
  }

  @override
  Future<DataState<String>> publishArticle(ArticleEntity article) async {
    try {
      // Convertimos Entity a Model para el DataSource
      final model = ArticleModel(
        id: article.id,
        author: article.author,
        title: article.title,
        description: article.description,
        content: article.content,
        url: article.url,
        thumbnailUrl: article.thumbnailUrl,
        publishedAt: article.publishedAt,
        isPublished: article.isPublished,
        isVisibleToPublic: article.isVisibleToPublic,
      );

      final docId = await _firebaseDataSource.publishArticle(model);
      return DataSuccess(docId);
    } on ServerException catch (e) {
      return DataFailed(DioError(
        requestOptions: RequestOptions(path: ''),
        message: e.message,
      ));
    }
  }
}


REGISTRO EN INJECTION_CONTAINER.DART
=====================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'features/articles/data/data_sources/articles_firebase_datasource.dart';

// En initializeDependencies():

// Firebase instances
final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;

// DataSource
sl.registerLazySingleton<ArticlesFirebaseDataSource>(
  () => ArticlesFirebaseDataSource(
    firestore: firestore,
    storage: storage,
  ),
);

// Repository (si ya existe)
sl.registerLazySingleton<ArticleRepository>(
  () => ArticleRepositoryImpl(sl()),
);


FLUJO DE DATOS
==============

UI → BLoC → UseCase → Repository → DataSource → Firebase
                                       ↓
                                 ArticleModel
                                       ↓
                              toEntity() → ArticleEntity
                                       ↓
                                    Domain


MANEJO DE ERRORES
=================

DataSource:
  - Captura FirebaseException
  - Lanza ServerException con mensaje y código

Repository:
  - Captura ServerException
  - Retorna DataState.error con DioError (para compatibilidad)

BLoC/UseCase:
  - Recibe DataState
  - Emite estados apropiados según success/error


EJEMPLO DE QUERY EN FIRESTORE
==============================

Collection: articles/
├── doc1: {
│     author: "Sarah Chen",
│     title: "Flutter 4.0...",
│     isPublished: true,
│     publishedAt: Timestamp(2026, 1, 15),
│     ...
│   }
├── doc2: { ... }
└── doc3: { ... }

Query aplicada:
  .where('isPublished', isEqualTo: true)
  .orderBy('publishedAt', descending: true)


NOTAS IMPORTANTES
=================

1. ✅ El DataSource SOLO lanza excepciones (nunca retorna DataState)
2. ✅ El DataSource SOLO conoce ArticleModel (no ArticleEntity)
3. ✅ El Repository convierte Model → Entity
4. ✅ El Repository convierte ServerException → DataState.error
5. ✅ Todas las operaciones son async
6. ✅ Las imágenes usan nombres únicos con timestamp

*/
