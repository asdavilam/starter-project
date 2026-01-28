import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';

void main() {
  group('ArticleEntity', () {
    final tArticle1 = ArticleEntity(
      id: '1',
      author: 'Author',
      title: 'Title',
      description: 'Desc',
      content: 'Content',
      thumbnailUrl: 'url',
      publishedAt:
          DateTime.fromMillisecondsSinceEpoch(0), // Fixed time for equality
      isPublished: true,
    );

    final tArticle2 = ArticleEntity(
      id: '1',
      author: 'Author',
      title: 'Title',
      description: 'Desc',
      content: 'Content',
      thumbnailUrl: 'url',
      publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
      isPublished: true,
    );

    test(
        'should support value equality (two instances with same data are equal)',
        () {
      // Assert
      expect(tArticle1, equals(tArticle2));
    });

    group('isVisibleToPublic Business Logic', () {
      test('should be TRUE when isPublished is true AND title is not empty',
          () {
        // Arrange
        final article = ArticleEntity(
          author: 'Author',
          title: 'Valid Title',
          description: 'Desc',
          content: 'Content',
          thumbnailUrl: 'url',
          publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
          isPublished: true,
        );

        // Act & Assert
        expect(article.isVisibleToPublic, true);
      });

      test('should be FALSE when isPublished is false (even with valid title)',
          () {
        // Arrange
        final article = ArticleEntity(
          author: 'Author',
          title: 'Valid Title',
          description: 'Desc',
          content: 'Content',
          thumbnailUrl: 'url',
          publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
          isPublished: false,
        );

        // Act & Assert
        expect(article.isVisibleToPublic, false);
      });

      test('should be FALSE when title is empty (even if isPublished is true)',
          () {
        // Arrange
        final article = ArticleEntity(
          author: 'Author',
          title: '', // Empty title
          description: 'Desc',
          content: 'Content',
          thumbnailUrl: 'url',
          publishedAt: DateTime.fromMillisecondsSinceEpoch(0),
          isPublished: true,
        );

        // Act & Assert
        expect(article.isVisibleToPublic, false);
      });
    });
  });
}
