import 'package:equatable/equatable.dart';

/// Entidad de dominio para Article
///
/// Representa el modelo de negocio central para artículos.
/// Solo contiene Dart puro - sin dependencias de Flutter o Firebase.
/// Usa Equatable para facilitar comparaciones y testing (única excepción permitida en domain).
class ArticleEntity extends Equatable {
  /// Identificador único del artículo
  final String? id;

  /// Autor del artículo
  final String author;

  /// Título del artículo
  final String title;

  /// Descripción breve del artículo
  final String description;

  /// Contenido completo del artículo
  final String content;

  /// URL del artículo original
  final String? url;

  /// URL de la imagen en miniatura
  final String thumbnailUrl;

  /// Fecha de publicación
  final DateTime publishedAt;

  /// Indica si el artículo está publicado
  final bool isPublished;

  const ArticleEntity({
    this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.content,
    this.url,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.isPublished,
  });

  /// Lógica de negocio: Un artículo es visible al público SI:
  /// 1. Está marcado como publicado
  /// 2. Tiene un título válido (no vacío)
  bool get isVisibleToPublic => isPublished && title.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        author,
        title,
        description,
        content,
        url,
        thumbnailUrl,
        publishedAt,
        isPublished,
        // isVisibleToPublic es derivado, no es necesario en identity,
        // pero isPublished y title ya determinan su valor.
      ];
}
