import 'dart:io';

import 'package:equatable/equatable.dart';

/// Eventos del PublishArticleBloc
///
/// Define todos los eventos relacionados con la publicación de artículos
abstract class PublishArticleEvent extends Equatable {
  const PublishArticleEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para enviar un artículo para publicación
///
/// Contiene todos los datos necesarios para publicar un artículo,
/// incluyendo la imagen que será subida a Firebase Storage
class SubmitArticle extends PublishArticleEvent {
  final String? id;
  final String title;
  final String author;
  final String description;
  final String content;
  final File? image;
  final String? currentImageUrl;
  final bool isUpdate;

  const SubmitArticle({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.content,
    this.image,
    this.currentImageUrl,
    this.isUpdate = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        content,
        image,
        currentImageUrl,
        isUpdate
      ];
}

/// Evento para guardar el artículo como borrador local
class SaveDraft extends PublishArticleEvent {
  final String? id;
  final String title;
  final String author;
  final String description;
  final String content;
  final String? imagePath;

  const SaveDraft({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.content,
    this.imagePath,
  });

  @override
  List<Object?> get props =>
      [id, title, author, description, content, imagePath];
}
