import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/articles/domain/use_cases/get_published_articles_use_case.dart';

// 1. Crear el Mock del repositorio
class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late GetPublishedArticlesUseCase useCase;
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
    useCase = GetPublishedArticlesUseCase(mockRepository);
  });

  // Datos de prueba
  final tArticles = [
    ArticleEntity(
      id: '1',
      author: 'Author',
      title: 'Title',
      description: 'Desc',
      content: 'Content',
      thumbnailUrl: 'url',
      publishedAt: DateTime.now(),
      isPublished: true,
    ),
  ];

  group('GetPublishedArticlesUseCase', () {
    test(
        'Happy Path: should return a list of articles when repository call is successful',
        () async {
      // Arrange
      when(() => mockRepository.getPublishedArticles())
          .thenAnswer((_) async => DataSuccess(tArticles));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, tArticles);
      verify(() => mockRepository.getPublishedArticles()).called(1);
    });

    test(
        'Error Path: should return a DataFailed when repository call is unsuccessful',
        () async {
      // Arrange
      final tError = DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Error fetching',
      );

      when(() => mockRepository.getPublishedArticles())
          .thenAnswer((_) async => DataFailed(tError));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, tError);
      verify(() => mockRepository.getPublishedArticles()).called(1);
    });
  });
}
