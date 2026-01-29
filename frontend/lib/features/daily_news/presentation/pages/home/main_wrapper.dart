import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../articles/presentation/bloc/publish_article_bloc.dart';
import '../../../../articles/presentation/bloc/publish_article_state.dart';
import '../../../../articles/presentation/pages/publish_article_page.dart';
import '../../../../../injection_container.dart';
import 'daily_news.dart';
import '../../../../articles/presentation/pages/drafts_page.dart';
import '../saved_article/saved_article.dart';

import '../../../../articles/presentation/bloc/drafts_cubit.dart';
import '../../../../account/presentation/pages/account_page.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class MainWrapper extends HookWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    final draftsCubit = useMemoized(() => sl<DraftsCubit>());
    final publishArticleBloc = useMemoized(() => sl<PublishArticleBloc>());
    final localArticleBloc = useMemoized(
        () => sl<LocalArticleBloc>()..add(const GetSavedArticles()));

    // Key to access PublishArticlePage state for navigation checks
    final publishPageKey =
        useMemoized(() => GlobalKey<PublishArticlePageState>());

    useEffect(() {
      return () {
        draftsCubit.close();
        publishArticleBloc.close();
        localArticleBloc.close();
      };
    }, [draftsCubit, publishArticleBloc, localArticleBloc]);

    Future<void> handleTabSelection(int index) async {
      // If leaving the "New Article" tab (index 2)
      if (selectedIndex.value == 2 && index != 2) {
        final canExit = await publishPageKey.currentState?.canExit();
        // If true (discarded or saved or no changes), we can leave.
        if (canExit == true) {
          // Clear the form to ensure clean state next time we return
          publishPageKey.currentState?.resetForm();
          selectedIndex.value = index;
        }
      } else {
        // Normal navigation
        selectedIndex.value = index;
      }
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: publishArticleBloc),
        BlocProvider.value(value: draftsCubit),
        BlocProvider.value(value: localArticleBloc),
      ],
      child: BlocListener<PublishArticleBloc, PublishArticleState>(
        listener: (context, state) {
          if (state is PublishArticleSuccess) {
            draftsCubit.loadDrafts();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: IndexedStack(
            index: selectedIndex.value,
            children: [
              // 0. Home
              const DailyNews(),
              // 1. Saved Articles (Bookmarks)
              const SavedArticles(),
              // 2. New Article (Publish)
              PublishArticlePage(
                key: publishPageKey,
                onCancel: () =>
                    handleTabSelection(0), // Default to home on cancel
              ),
              // 3. Drafts
              const DraftsPage(),
              // 4. Account
              const AccountPage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex.value,
              onTap: (index) {
                if (index == 1) {
                  // Refresh Saved Articles when tapping the tab
                  localArticleBloc.add(const GetSavedArticles());
                }
                if (index == 3) {
                  draftsCubit.loadDrafts();
                }
                handleTabSelection(index);
              },
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Inicio',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border),
                  label: 'Guardados',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  label: 'Nuevo',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.drive_file_rename_outline),
                  label: 'Borradores',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Cuenta',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
