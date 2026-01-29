import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/article_repository.dart';

class DeleteDraftUseCase implements UseCase<DataState<void>, String> {
  final ArticleRepository _articleRepository;

  DeleteDraftUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call({String? params}) {
    return _articleRepository.deleteDraft(params!);
  }
}
