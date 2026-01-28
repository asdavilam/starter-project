import 'package:equatable/equatable.dart';

/// Estados del PublishArticleBloc
///
/// Define todos los posibles estados durante la publicación de un artículo
abstract class PublishArticleState extends Equatable {
  final String? error;

  const PublishArticleState({this.error});

  @override
  List<Object?> get props => [error];
}

/// Estado inicial
///
/// El formulario está listo pero no se ha enviado nada
class PublishArticleInitial extends PublishArticleState {
  const PublishArticleInitial();
}

/// Estado de publicación en proceso
///
/// Indica que el artículo se está enviando
class PublishArticleSubmitting extends PublishArticleState {
  const PublishArticleSubmitting();
}

/// Estado de publicación exitosa
///
/// Indica que el artículo se publicó correctamente
class PublishArticleSuccess extends PublishArticleState {
  const PublishArticleSuccess();
}

/// Estado de error
///
/// Indica que ocurrió un error durante la publicación
class PublishArticleFailure extends PublishArticleState {
  const PublishArticleFailure(String error) : super(error: error);
}
