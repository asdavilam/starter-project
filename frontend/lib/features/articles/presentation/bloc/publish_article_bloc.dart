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
import '../../domain/use_cases/save_draft_use_case.dart';
import '../../domain/use_cases/update_article_use_case.dart';

class PublishArticleBloc
    extends Bloc<PublishArticleEvent, PublishArticleState> {
  final UploadArticleImageUseCase _uploadImageUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;

  PublishArticleBloc(
    this._uploadImageUseCase,
    this._createArticleUseCase,
    this._saveDraftUseCase,
    this._updateArticleUseCase,
  ) : super(const PublishArticleInitial()) {
    on<SubmitArticle>(_onSubmitArticle);
    on<SaveDraft>(_onSaveDraft);
  }

  Future<void> _onSaveDraft(
    SaveDraft event,
    Emitter<PublishArticleState> emit,
  ) async {
    try {
      final article = ArticleEntity(
        id: event.id,
        title: event.title,
        author: event.author,
        description: event.description,
        content: event.content,
        thumbnailUrl: event.imagePath ?? '',
        publishedAt: DateTime.now(),
        isPublished: false,
      );

      final result = await _saveDraftUseCase.call(params: article);

      if (result is DataSuccess && result.data != null) {
        emit(SaveDraftSuccess(result.data!));
      } else {
        emit(PublishArticleFailure(
            result.error?.message ?? 'Error desconocido al guardar borrador'));
      }
    } catch (e) {
      emit(PublishArticleFailure('Error al guardar borrador: $e'));
    }
  }

  /// Maneja el evento SubmitArticle con flujo secuencial validado
  Future<void> _onSubmitArticle(
    SubmitArticle event,
    Emitter<PublishArticleState> emit,
  ) async {
    emit(const PublishArticleSubmitting());

    // Create initial article entity (without image URL yet)
    final articleToPublish = ArticleEntity(
      id: event.id,
      author: event.author,
      title: event.title,
      description: event.description,
      content: event.content,
      thumbnailUrl: '', // Will be updated after upload
      publishedAt: DateTime.now(),
      isPublished: true,
    );

    try {
      // Paso 1: Subir imagen a Storage (si se seleccionó una nueva)
      String downloadUrl;

      if (event.image != null) {
        final uploadResult = await _uploadImageUseCase.call(event.image!);

        // Verificar si la subida falló
        if (uploadResult is DataFailed) {
          // Fallback: Guardar borrador si falla la subida
          await _saveDraftUseCase.call(params: articleToPublish);
          emit(const PublishArticleFailure(
              'Error de red al subir imagen. Artículo guardado en borradores.'));
          return;
        } else {
          downloadUrl = (uploadResult as DataSuccess<String>).data!;
        }
      } else {
        // Si no hay nueva imagen, usar la existente (para updates)
        downloadUrl = event.currentImageUrl ?? '';

        // Si es CREATE y no hay imagen, debería haber sido validado en UI,
        // pero por seguridad usamos string vacío o fallback.
      }

      // Paso 2: Crear ArticleEntity actualizado con la URL de la imagen
      final updatedArticle = ArticleEntity(
        id: articleToPublish.id,
        author: articleToPublish.author,
        title: articleToPublish.title,
        description: articleToPublish.description,
        content: articleToPublish.content,
        url: articleToPublish.url,
        thumbnailUrl: downloadUrl,
        publishedAt: articleToPublish.publishedAt,
        isPublished: articleToPublish.isPublished,
      );

      // Paso 3: Crear o Actualizar en Firestore
      dynamic result;
      if (event.isUpdate) {
        result = await _updateArticleUseCase.call(params: updatedArticle);
      } else {
        result = await _createArticleUseCase.call(updatedArticle);
      }

      // Verificar resultado
      if (result is DataFailed) {
        // Si falla Firestore, también guardamos borrador
        await _saveDraftUseCase.call(params: updatedArticle);
        final errorMessage = result.error?.message ??
            'Error al publicar. Se guardó copia local.';
        emit(PublishArticleFailure(errorMessage));
        return;
      }

      // Éxito completo
      emit(const PublishArticleSuccess());
    } catch (e) {
      // Captura global: guardar borrador
      try {
        await _saveDraftUseCase.call(params: articleToPublish);
      } catch (_) {} // Ignore draft save error
      emit(PublishArticleFailure('Error inesperado: $e. Borrador guardado.'));
    }
  }
}
