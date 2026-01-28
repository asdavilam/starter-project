import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/use_cases/get_published_articles_use_case.dart';
import 'remote_articles_event.dart';
import 'remote_articles_state.dart';

/// BLoC para gestionar artículos remotos
///
/// Responsable de coordinar la obtención de artículos publicados
/// interactuando exclusivamente con UseCases (sin acceso directo a repositorios)
class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;

  RemoteArticlesBloc(this._getPublishedArticlesUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(_onGetArticles);
  }

  /// Maneja el evento GetArticles
  ///
  /// Invoca el use case para obtener artículos publicados
  /// y emite los estados correspondientes según el resultado
  Future<void> _onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(const RemoteArticlesLoading());

    try {
      // Llama al UseCase que ahora retorna Future<DataState>
      final dataState = await _getPublishedArticlesUseCase.call();

      // Procesa el DataState
      if (dataState is DataSuccess) {
        emit(RemoteArticlesDone(dataState.data!));
      } else if (dataState is DataFailed) {
        emit(RemoteArticlesError(
            dataState.error!.message ?? 'Error desconocido'));
      }
    } catch (e) {
      // Captura cualquier error inesperado
      emit(RemoteArticlesError('Error inesperado: $e'));
    }
  }
}
