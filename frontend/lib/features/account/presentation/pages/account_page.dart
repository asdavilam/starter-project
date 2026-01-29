import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../injection_container.dart';
import '../bloc/account_cubit.dart';
import '../bloc/account_state.dart';
import '../../../subscription/presentation/cubit/subscription_cubit.dart';
import '../../../subscription/presentation/cubit/subscription_state.dart';
import '../../../articles/presentation/widgets/my_article_tile.dart';
import '../../../articles/presentation/pages/publish_article_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
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
          AppConstants.myAccountTitle,
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
              const _SubscriptionAdminPanel(),
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
              return Dismissible(
                key: Key('article_${article.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 30),
                ),
                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmation(
                      context, article.id.toString());
                },
                onDismissed: (direction) {
                  context
                      .read<AccountCubit>()
                      .deleteArticle(article.id.toString());
                },
                child: MyArticleTile(
                  article: article,
                  isRemovable: false, // Handled by Dismissible now
                  onRemove: null,
                  onArticlePressed: (article) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => sl<PublishArticleBloc>(),
                          child: PublishArticlePage(articleToEdit: article),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String articleId) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(AppConstants.deleteArticleTitle),
            content: const Text(AppConstants.deleteArticleContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(AppConstants.cancelAction),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(AppConstants.deleteAction,
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
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

class _SubscriptionAdminPanel extends StatelessWidget {
  const _SubscriptionAdminPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          final isPro = state.isPro;
          final remaining = state.remainingRequests;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient:
                  isPro ? AppColors.premiumGradient : AppColors.freeGradient,
              boxShadow: [
                BoxShadow(
                  color: isPro
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPro ? Icons.workspace_premium : Icons.stars,
                        color: isPro ? Colors.black87 : Colors.grey[700],
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.subscriptionSimulationTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isPro ? Colors.black87 : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPro
                          ? AppConstants.premiumStatusLabel
                          : AppConstants.freeStatusLabel,
                      style: TextStyle(
                        color: isPro ? Colors.black87 : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  if (!isPro) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppConstants.availableCreditsLabel,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$remaining/20',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: remaining / 20.0,
                        minHeight: 8,
                        backgroundColor: Colors.white54,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remaining > 5 ? Colors.blueAccent : Colors.red,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isPro) {
                              context
                                  .read<SubscriptionCubit>()
                                  .downgradeToFree();
                            } else {
                              context.read<SubscriptionCubit>().upgradeToPro();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isPro
                                ? AppConstants.downgradeButtonLabel
                                : AppConstants.upgradeButtonLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (!isPro) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            context.read<SubscriptionCubit>().downgradeToFree();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black54,
                          ),
                          child: const Text(AppConstants.resetButtonLabel),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
