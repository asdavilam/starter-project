import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/article_entity.dart';

/// Modelo de datos para Article
///
/// Extiende ArticleEntity y agrega métodos de serialización/deserialización
/// para Firestore. Maneja la conversión entre el modelo de dominio puro
/// y el formato de datos de Firebase.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    super.id,
    required super.author,
    required super.title,
    required super.description,
    required super.content,
    super.url,
    required super.thumbnailUrl,
    required super.publishedAt,
    required super.isPublished,
  });

  /// Convierte el modelo a la entidad de dominio
  ///
  /// Este método permite que la capa de datos retorne
  /// entidades puras de dominio al repositorio
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      author: author,
      title: title,
      description: description,
      content: content,
      url: url,
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
      isPublished: isPublished,
    );
  }

  /// Crea un ArticleModel desde un documento de Firestore
  ///
  /// [doc] - DocumentSnapshot de Firestore
  /// Retorna un ArticleModel con los datos del documento
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ArticleModel(
      id: doc.id,
      author: data['author'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      content: data['content'] as String? ?? '',
      url: data['url'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      publishedAt:
          (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] as bool? ?? false,
      // isVisibleToPublic se ignora al leer, se calcula por lógica de dominio
    );
  }

  /// Convierte el modelo a un Map para Firestore
  ///
  /// Retorna un Map que puede ser usado para crear/actualizar
  /// documentos en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'isPublished': isPublished,
      'isVisibleToPublic': isVisibleToPublic, // Se guarda el valor calculado
    };
  }

  /// Crea una copia del modelo con campos actualizados
  ArticleModel copyWith({
    String? id,
    String? author,
    String? title,
    String? description,
    String? content,
    String? url,
    String? thumbnailUrl,
    DateTime? publishedAt,
    bool? isPublished,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
