import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/resources/data_state.dart';
import '../../../articles/domain/use_cases/get_published_articles_use_case.dart';
import '../../../articles/domain/use_cases/delete_article_use_case.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetPublishedArticlesUseCase _getPublishedArticlesUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  AccountCubit(
    this._getPublishedArticlesUseCase,
    this._deleteArticleUseCase,
  ) : super(const AccountInitial());

  Future<void> loadAccountData() async {
    emit(const AccountLoading());
    final dataState = await _getPublishedArticlesUseCase.call();

    if (dataState is DataSuccess && dataState.data != null) {
      emit(AccountLoaded(myArticles: dataState.data!));
    } else {
      emit(AccountError(dataState.error!));
    }
  }

  Future<void> deleteArticle(String id) async {
    // Optimistic update: Keep current state but reload after delete
    final result = await _deleteArticleUseCase.call(params: id);

    if (result is DataSuccess) {
      // Refresh list after successful deletion
      loadAccountData();
    } else {
      // Emit error only if strictly necessary, or just snackbar in UI?
      // Since Cubit emits state, let's emit error to show feedback
      emit(AccountError(result.error!));
      // Then revert to loaded? Or reload?
      loadAccountData();
    }
  }
}
