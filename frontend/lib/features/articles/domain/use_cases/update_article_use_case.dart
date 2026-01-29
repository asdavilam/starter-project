import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article_entity.dart';
import '../repository/article_repository.dart';

class UpdateArticleUseCase implements UseCase<DataState<void>, ArticleEntity> {
  final ArticleRepository _articleRepository;

  UpdateArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call({ArticleEntity? params}) {
    return _articleRepository.updateArticle(params!);
  }
}
