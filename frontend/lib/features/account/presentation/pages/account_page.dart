import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../injection_container.dart';
import '../bloc/account_cubit.dart';
import '../bloc/account_state.dart';
import '../../../articles/presentation/widgets/my_article_tile.dart';
import '../../../articles/presentation/pages/publish_article_page.dart';
import '../../../articles/presentation/bloc/publish_article_bloc.dart';

class AccountPage extends HookWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AccountCubit>()..loadAccountData(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends HookWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Cuenta',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: Colors.black,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await context.read<AccountCubit>().loadAccountData();
        },
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensure refresh works even if list is short
          child: Column(
            children: [
              const _MockUserProfile(),
              const Divider(thickness: 1),
              _buildMyArticlesList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyArticlesList(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AccountError) {
          return Center(child: Text('Error: ${state.error.message}'));
        } else if (state is AccountLoaded) {
          if (state.myArticles.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No has publicado artículos aún.'),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.myArticles.length,
            itemBuilder: (context, index) {
              final article = state.myArticles[index];
              return MyArticleTile(
                article: article,
                isRemovable: true,
                onRemove: (articleToRemove) {
                  _showDeleteConfirmation(context, articleToRemove.id!);
                },
                onArticlePressed: (article) {
                  // Navigate to PublishArticlePage for editing
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => sl<PublishArticleBloc>(),
                        child: PublishArticlePage(articleToEdit: article),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String articleId) {
    // Capture the cubit instance BEFORE opening the dialog
    // because dialog context is not a child of BlocProvider
    final accountCubit = context.read<AccountCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este artículo publicado? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              accountCubit.deleteArticle(articleId);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MockUserProfile extends StatelessWidget {
  const _MockUserProfile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Usuario Demo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Desarrollador Flutter & Entusiasta de Clean Architecture',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat('Artículos', '12'),
              const SizedBox(width: 20),
              _buildStat('Seguidores', '250'),
              const SizedBox(width: 20),
              _buildStat('Siguiendo', '180'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
