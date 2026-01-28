import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/article_entity.dart';

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
  final ArticleEntity article;
  final File image;

  const SubmitArticle({
    required this.article,
    required this.image,
  });

  @override
  List<Object?> get props => [article, image];
}
