import '../../../../core/resources/data_state.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';

/// Use Case para obtener artículos publicados
///
/// Retorna únicamente los artículos que tienen isPublished: true
/// Implementa el patrón Use Case con método call() para ejecutar la lógica de negocio
class GetPublishedArticlesUseCase {
  final ArticleRepository _repository;

  GetPublishedArticlesUseCase(this._repository);

  /// Obtiene la lista de artículos publicados
  ///
  /// Llama al repositorio para obtener artículos filtrados por isPublished: true
  /// Retorna DataState<List<ArticleEntity>>
  Future<DataState<List<ArticleEntity>>> call() {
    return _repository.getPublishedArticles();
  }
}
