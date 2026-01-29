import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart'
    as new_article;
import 'package:news_app_clean_architecture/features/articles/domain/use_cases/get_published_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart'
    as legacy_article;
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

// Mocks
class MockGetPublishedArticlesUseCase extends Mock
    implements GetPublishedArticlesUseCase {}

class MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

void main() {
  late RemoteArticlesBloc bloc;
  late MockGetPublishedArticlesUseCase mockGetPublishedArticlesUseCase;
  late MockGetArticleUseCase mockGetArticleUseCase;

  setUp(() {
    mockGetPublishedArticlesUseCase = MockGetPublishedArticlesUseCase();
    mockGetArticleUseCase = MockGetArticleUseCase();
    bloc = RemoteArticlesBloc(
      mockGetPublishedArticlesUseCase,
      mockGetArticleUseCase,
    );
  });

  // Datos de prueba
  final tNewArticles = [
    new_article.ArticleEntity(
      id: '1',
      author: 'Author',
      title: 'New Title',
      description: 'Desc',
      content: 'Content',
      thumbnailUrl: 'url',
      publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
      isPublished: true,
    ),
  ];

  final tLegacyArticles = [
    const legacy_article.ArticleEntity(
      id: 2,
      author: 'Old Author',
      title: 'Old Title',
      description: 'Old Desc',
      url: 'url',
      urlToImage: 'url',
      publishedAt: '2023-01-01T00:00:00Z',
      content: 'Old Content',
    ),
  ];

  group('RemoteArticlesBloc', () {
    test('initial state should be RemoteArticlesLoading', () {
      expect(bloc.state, isA<RemoteArticlesLoading>());
    });

    blocTest<RemoteArticlesBloc, RemoteArticlesState>(
      'should emit [RemoteArticlesDone] with combined articles when data is successful',
      build: () {
        // Simular éxito en ambas fuentes
        when(() => mockGetPublishedArticlesUseCase())
            .thenAnswer((_) async => DataSuccess(tNewArticles));
        when(() => mockGetArticleUseCase())
            .thenAnswer((_) async => DataSuccess(tLegacyArticles));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetArticles()),
      expect: () => [
        isA<RemoteArticlesLoading>(),
        isA<RemoteArticlesDone>(),
      ],
      verify: (bloc) {
        verify(() => mockGetPublishedArticlesUseCase()).called(1);
        verify(() => mockGetArticleUseCase()).called(1);
      },
    );

    blocTest<RemoteArticlesBloc, RemoteArticlesState>(
      'should emit [RemoteArticlesError] when both sources fail',
      build: () {
        // Simular fallo en ambas fuentes
        final error = DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Error',
        );
        when(() => mockGetPublishedArticlesUseCase())
            .thenAnswer((_) async => DataFailed(error));
        when(() => mockGetArticleUseCase())
            .thenAnswer((_) async => DataFailed(error));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetArticles()),
      expect: () => [
        isA<RemoteArticlesLoading>(),
        isA<RemoteArticlesError>(),
      ],
    );
  });
}
