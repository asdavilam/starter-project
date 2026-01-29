import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/draft_article_model.dart';
import '../../../domain/entities/article_entity.dart';

abstract class ArticlesLocalDataSource {
  Future<ArticleEntity> saveDraft(ArticleEntity article);
  Future<List<ArticleEntity>> getDrafts();
  Future<void> deleteDraft(String id);
}

class ArticlesLocalDataSourceImpl implements ArticlesLocalDataSource {
  final SharedPreferences sharedPreferences;

  ArticlesLocalDataSourceImpl({required this.sharedPreferences});

  static const String _draftsKey = 'CACHED_DRAFTS_LIST';

  @override
  Future<ArticleEntity> saveDraft(ArticleEntity article) async {
    final drafts = await getDrafts();

    // Generate UUID if id is null or empty
    final id = article.id != null && article.id!.isNotEmpty
        ? article.id!
        : DateTime.now()
            .millisecondsSinceEpoch
            .toString(); // Simple ID generation

    final draftModel = DraftArticleModel(
      id: id,
      author: article.author,
      title: article.title,
      description: article.description,
      content: article.content,
      url: article.url,
      thumbnailUrl: article.thumbnailUrl,
      publishedAt: article.publishedAt,
      isPublished: article.isPublished,
    );

    // Remove existing draft with same ID if exists (update)
    final updatedDrafts = drafts.where((d) => d.id != id).toList();
    updatedDrafts.add(draftModel);

    final jsonList = updatedDrafts
        .map((d) => DraftArticleModel.fromEntity(d).toJson())
        .toList();

    await sharedPreferences.setString(_draftsKey, jsonEncode(jsonList));

    return draftModel;
  }

  @override
  Future<List<ArticleEntity>> getDrafts() async {
    final jsonString = sharedPreferences.getString(_draftsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((j) => DraftArticleModel.fromJson(j)).toList();
    }
    return [];
  }

  @override
  Future<void> deleteDraft(String id) async {
    final drafts = await getDrafts();
    final updatedDrafts = drafts.where((d) => d.id != id).toList();

    final jsonList = updatedDrafts
        .map((d) => DraftArticleModel.fromEntity(d).toJson())
        .toList();

    await sharedPreferences.setString(_draftsKey, jsonEncode(jsonList));
  }
}
