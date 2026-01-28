import 'package:equatable/equatable.dart';

/// Eventos del RemoteArticlesBloc
///
/// Define todos los eventos que pueden ser despachados al bloc
/// para gestionar la obtención de artículos remotos
abstract class RemoteArticlesEvent extends Equatable {
  const RemoteArticlesEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para obtener artículos
///
/// Al dispararse, el bloc invocará al GetPublishedArticlesUseCase
/// para obtener los artículos publicados
class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}
