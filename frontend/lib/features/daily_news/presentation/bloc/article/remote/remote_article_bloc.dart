import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    print('🔍 Starting to fetch articles...');
    final dataState = await _getArticleUseCase();

    print('📦 DataState type: ${dataState.runtimeType}');

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      print('✅ Success! Got ${dataState.data!.length} articles');
      emit(RemoteArticlesDone(dataState.data!));
    }

    if (dataState is DataFailed) {
      print('❌ Error: ${dataState.error}');
      emit(RemoteArticlesError(dataState.error!));
    }
  }
}
