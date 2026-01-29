import '../entities/article_entity.dart';
import '../repository/article_repository.dart';
import '../../../../core/resources/data_state.dart'; // Assuming this path for DataState
import '../../../../core/usecase/usecase.dart'; // Assuming this path for UseCase

class SaveDraftUseCase implements UseCase<DataState<ArticleEntity>, ArticleEntity> {
  final ArticleRepository _articleRepository;

  SaveDraftUseCase(this._articleRepository);

  @override
  Future<DataState<ArticleEntity>> call({ArticleEntity? params}) {
    return _articleRepository.saveDraft(params!);
  }
}
