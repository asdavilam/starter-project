import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

// Articles Feature imports
import 'features/articles/data/data_sources/articles_firebase_datasource.dart';
import 'features/articles/data/data_sources/local/articles_local_data_source.dart';
import 'features/articles/data/repository/article_repository_impl.dart'
    as articles_repo;
import 'features/articles/domain/repository/article_repository.dart'
    as articles_domain;
import 'features/articles/domain/use_cases/get_published_articles_use_case.dart';
import 'features/articles/domain/use_cases/get_all_articles_use_case.dart';
import 'features/articles/domain/use_cases/upload_article_image_use_case.dart';
import 'features/articles/domain/use_cases/create_article_use_case.dart';
import 'features/articles/domain/use_cases/save_draft_use_case.dart';
import 'features/articles/domain/use_cases/get_drafts_use_case.dart';
import 'features/articles/domain/use_cases/delete_draft_use_case.dart';
import 'features/articles/presentation/bloc/remote_articles_bloc.dart'
    as articles_bloc;
import 'features/articles/presentation/bloc/publish_article_bloc.dart';
import 'features/articles/presentation/bloc/drafts_cubit.dart';
import 'features/articles/domain/use_cases/update_article_use_case.dart';
import 'features/articles/domain/use_cases/delete_article_use_case.dart';
import 'features/account/presentation/bloc/account_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));

  //UseCases
  sl.registerSingleton<GetArticleUseCase>(GetArticleUseCase(sl()));

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl(), sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));

  // ... DI setup ...
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  // Articles Feature - DataSource
  sl.registerLazySingleton<ArticlesFirebaseDataSource>(
    () => ArticlesFirebaseDataSource(
      firestore: firestore,
      storage: storage,
    ),
  );

  sl.registerLazySingleton<ArticlesLocalDataSource>(
    () => ArticlesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Articles Feature - Repository
  sl.registerLazySingleton<articles_domain.ArticleRepository>(
    () => articles_repo.ArticleRepositoryImpl(sl(), sl()),
  );

  // Articles Feature - UseCases
  sl.registerLazySingleton<GetPublishedArticlesUseCase>(
    () => GetPublishedArticlesUseCase(sl()),
  );

  sl.registerLazySingleton<GetAllArticlesUseCase>(
    () => GetAllArticlesUseCase(sl()),
  );

  sl.registerLazySingleton<UploadArticleImageUseCase>(
    () => UploadArticleImageUseCase(sl()),
  );

  sl.registerLazySingleton<CreateArticleUseCase>(
    () => CreateArticleUseCase(sl()),
  );

  sl.registerLazySingleton<SaveDraftUseCase>(
    () => SaveDraftUseCase(sl()),
  );

  sl.registerLazySingleton<GetDraftsUseCase>(
    () => GetDraftsUseCase(sl()),
  );

  sl.registerLazySingleton<DeleteDraftUseCase>(
    () => DeleteDraftUseCase(sl()),
  );

  sl.registerLazySingleton<DeleteArticleUseCase>(
    () => DeleteArticleUseCase(sl()),
  );

  sl.registerLazySingleton<UpdateArticleUseCase>(
    () => UpdateArticleUseCase(sl()),
  );

  // Articles Feature - Blocs
  sl.registerFactory<articles_bloc.RemoteArticlesBloc>(
    () => articles_bloc.RemoteArticlesBloc(sl()),
  );

  sl.registerFactory<PublishArticleBloc>(
    () => PublishArticleBloc(sl(), sl(), sl(), sl()),
  );

  sl.registerFactory<DraftsCubit>(
    () => DraftsCubit(sl(), sl()),
  );

  sl.registerFactory<AccountCubit>(
    () => AccountCubit(sl(), sl()),
  );
}
