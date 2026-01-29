import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/article_entity.dart';
import '../bloc/drafts_cubit.dart';
import '../bloc/publish_article_bloc.dart';
import 'publish_article_page.dart';
import '../../../../core/constants/app_constants.dart';

class DraftsPage extends StatelessWidget {
  const DraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cubit is now provided by MainWrapper via BlocProvider.value
    // Trigger load is done by MainWrapper on tab change.
    // However, for initial load or safety, we can leave it?
    // MainWrapper manages it. DraftsPage is just the view.
    return const _DraftsView();
  }
}

class _DraftsView extends StatelessWidget {
  const _DraftsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Borradores',
          style: TextStyle(
            fontFamily: 'Butler',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<DraftsCubit, DraftsState>(
        builder: (context, state) {
          if (state is DraftsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DraftsEmpty) {
            return _buildEmptyState(context);
          }

          if (state is DraftsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<DraftsCubit>().loadDrafts(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.drafts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final draft = state.drafts[index];
                  return _DraftItem(draft: draft);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay borradores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus ideas guardadas aparecerán aquí',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _DraftItem extends StatelessWidget {
  final ArticleEntity draft;

  const _DraftItem({required this.draft});

  @override
  Widget build(BuildContext context) {
    // Use a unique key. Ideally ID. If ID missing, fallback to unique object identity hash
    // to prevent "Dismissible still in tree" error if titles are duplicate.
    final key = draft.id != null ? Key(draft.id!) : ObjectKey(draft);

    // If ID is null, we can't reliably delete it via ID.
    // Ensure we don't crash.
    final canDismiss = draft.id != null;

    if (!canDismiss) {
      // Non-dismissible version if data is incomplete
      return _buildCardContent(context);
    }

    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) {
        if (draft.id != null) {
          context.read<DraftsCubit>().deleteDraft(draft.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppConstants.draftDeletedMessage)),
          );
        } else {
          context.read<DraftsCubit>().loadDrafts();
        }
      },
      child: _buildCardContent(context),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(AppConstants.deleteDraftTitle),
            content: const Text(AppConstants.deleteDraftContent),
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

  Widget _buildCardContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to PublishArticlePage in Edit Mode
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<PublishArticleBloc>(), // New bloc instance
              child: PublishArticlePage(draft: draft),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (draft.title.isNotEmpty)
              Text(
                draft.title,
                style: const TextStyle(
                  fontFamily: 'Butler',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              const Text(
                '(Sin Título)',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              draft.content.isNotEmpty ? draft.content : 'Sin contenido...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Guardado el ${draft.publishedAt.day}/${draft.publishedAt.month}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
