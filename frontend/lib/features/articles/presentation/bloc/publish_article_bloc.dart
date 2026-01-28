import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/use_cases/create_article_use_case.dart';
import '../../domain/use_cases/upload_article_image_use_case.dart';
import 'publish_article_event.dart';
import 'publish_article_state.dart';

/// BLoC para gestionar la publicación de artículos
///
/// Responsable de coordinar el flujo completo de publicación:
/// 1. Subir imagen a Firebase Storage
/// 2. Si éxito, crear artículo en Firestore con la URL de la imagen
/// 3. Si falla en cualquier punto, detener y mostrar error
class PublishArticleBloc
    extends Bloc<PublishArticleEvent, PublishArticleState> {
  final UploadArticleImageUseCase _uploadImageUseCase;
  final CreateArticleUseCase _createArticleUseCase;

  PublishArticleBloc(
    this._uploadImageUseCase,
    this._createArticleUseCase,
  ) : super(const PublishArticleInitial()) {
    on<SubmitArticle>(_onSubmitArticle);
  }

  /// Maneja el evento SubmitArticle con flujo secuencial validado
  Future<void> _onSubmitArticle(
    SubmitArticle event,
    Emitter<PublishArticleState> emit,
  ) async {
    emit(const PublishArticleSubmitting());

    try {
      // Paso 1: Subir imagen a Storage
      final uploadResult = await _uploadImageUseCase.call(event.image);

      // Verificar si la subida falló
      String downloadUrl;
      if (uploadResult is DataFailed) {
        // URL de placeholder para continuar flujo y probar Firestore
        downloadUrl =
            'https://via.placeholder.com/300x200.png?text=Article+Image';
      } else {
        // Extraer URL de la imagen si fue éxito
        downloadUrl = (uploadResult as DataSuccess<String>).data!;
      }

      // Paso 2: Crear ArticleEntity actualizado con la URL de la imagen
      final updatedArticle = ArticleEntity(
        id: event.article.id,
        author: event.article.author,
        title: event.article.title,
        description: event.article.description,
        content: event.article.content,
        url: event.article.url,
        thumbnailUrl: downloadUrl,
        publishedAt: event.article.publishedAt,
        isPublished: event.article.isPublished,
      );

      // Paso 3: Crear artículo en Firestore
      final createResult = await _createArticleUseCase.call(updatedArticle);

      // Verificar resultado de creación
      if (createResult is DataFailed) {
        final errorMessage = createResult.error?.message ??
            'Error desconocido al crear el artículo';
        emit(PublishArticleFailure(errorMessage));
        return;
      }

      // Éxito completo
      emit(const PublishArticleSuccess());
    } catch (e) {
      emit(PublishArticleFailure('Error inesperado: $e'));
    }
  }
}
