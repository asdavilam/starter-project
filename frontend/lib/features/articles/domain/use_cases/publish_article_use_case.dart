import '../entities/article_entity.dart';

/// Use Case para publicar un artículo
///
/// Recibe los datos del artículo y coordina su publicación
/// Implementa el patrón Use Case con método call() para ejecutar la lógica de negocio
class PublishArticleUseCase {
  /// Publica un nuevo artículo
  ///
  /// [article] - El artículo a publicar
  /// Por ahora solo simula la publicación. En producción, esto debe
  /// llamar al repositorio para guardar en Firebase.
  void call(ArticleEntity article) {
    // NOTE: Esto es solo para desarrollo/debug
    // En producción, este UseCase debería:
    // 1. Recibir el ArticleRepository como dependencia
    // 2. Llamar a _repository.publishArticle(article)
    // 3. Retornar DataState<String> con el ID del artículo creado

    // TODO: Implementar llamada real al repositorio
    // _repository.publishArticle(article);
  }
}
