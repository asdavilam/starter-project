import '../../../../core/resources/data_state.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';

/// Use Case para crear artículos en Firestore
///
/// Responsable de coordinar la creación de nuevos artículos.
/// Sigue el patrón Single Responsibility: solo maneja creación de artículos.
class CreateArticleUseCase {
  final ArticleRepository _repository;

  CreateArticleUseCase(this._repository);

  /// Crea un nuevo artículo en Firestore
  ///
  /// [article] - La entidad del artículo a crear (debe incluir thumbnailUrl)
  ///
  /// Retorna DataState<String> con el ID del artículo en caso de éxito
  /// o un error en caso de fallo.
  Future<DataState<String>> call(ArticleEntity article) {
    return _repository.createArticle(article);
  }
}
