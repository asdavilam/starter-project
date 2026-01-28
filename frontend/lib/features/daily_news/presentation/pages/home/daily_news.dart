import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Butler',
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon:
              const Icon(Icons.notifications_none_rounded, color: Colors.black),
        ),
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark_border_rounded, color: Colors.black),
          ),
        ),
      ],
    );
  }

  _buildPage() {
    return BlocConsumer<RemoteArticlesBloc, RemoteArticlesState>(
      listener: (context, state) {
        if (state is RemoteArticlesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${state.error ?? "No se pudo actualizar"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // 1. Si hay datos (ya sea Done, Loading con datos, o Error con datos) mostramos la lista
        if (state.articles != null && state.articles!.isNotEmpty) {
          return _buildArticlesPage(context, state.articles!);
        }

        // 2. Si no hay datos y está cargando, mostramos spinner centro
        if (state is RemoteArticlesLoading) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: const Center(child: CupertinoActivityIndicator()));
        }

        // 3. Si no hay datos y hay error, mostramos pantalla de error
        if (state is RemoteArticlesError) {
          return Scaffold(
              appBar: _buildAppbar(context),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No pudimos cargar las noticias',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.error ?? 'Error desconocido',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<RemoteArticlesBloc>()
                            .add(const GetArticles());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ));
        }

        // 4. Default / Empty
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<RemoteArticlesBloc>().add(const GetArticles());
          // Esperar un poco o hasta que termine el loading?
          // RefreshIndicator espera un Future.

          // Opción pro: Esperar a que el estado cambie.
          // Opción simple: Delay fijo o null (no bloqueante visualmente gracias al bloc).
          // Dado que el bloc emite estados, podemos simplemente retornar.
          return Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return ArticleWidget(
              article: articles[index],
              onArticlePressed: (article) =>
                  _onArticlePressed(context, article),
            );
          },
        ),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
