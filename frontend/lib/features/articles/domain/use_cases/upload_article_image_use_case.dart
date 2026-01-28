import 'dart:io';

import '../../../../core/resources/data_state.dart';
import '../repository/article_repository.dart';

/// Use Case para subir imágenes de artículos a Firebase Storage
///
/// Responsable de coordinar la subida de imágenes de artículos.
/// Sigue el patrón Single Responsibility: solo maneja upload de imágenes.
class UploadArticleImageUseCase {
  final ArticleRepository _repository;

  UploadArticleImageUseCase(this._repository);

  /// Sube una imagen de artículo y retorna la URL de descarga
  ///
  /// [image] - Archivo de imagen a subir
  ///
  /// Retorna DataState<String> con la URL en caso de éxito
  /// o un error en caso de fallo.
  Future<DataState<String>> call(File image) {
    return _repository.uploadArticleImage(image);
  }
}
