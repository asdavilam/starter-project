import '../../../../core/resources/data_state.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';

/// Use Case para obtener todos los artículos
///
/// Retorna todos los artículos sin aplicar ningún filtro
/// Implementa el patrón Use Case con método call() para ejecutar la lógica de negocio
class GetAllArticlesUseCase {
  final ArticleRepository _repository;

  GetAllArticlesUseCase(this._repository);

  /// Obtiene la lista completa de artículos
  ///
  /// Llama al repositorio para obtener todos los artículos
  /// Retorna DataState<List<ArticleEntity>>
  Future<DataState<List<ArticleEntity>>> call() {
    return _repository.getArticles();
  }
}
