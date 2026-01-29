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
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _getPage(selectedIndex.value, publishPageKey,
                () => handleTabSelection(0)),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  10, 0, 10, 10), // Reduced L/R padding
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.transparent, // Floating feel
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(context, 0, Icons.home_filled, 'Inicio',
                        selectedIndex.value,
                        onTap: () => handleTabSelection(0)),
                    _buildNavItem(context, 1, Icons.bookmark_border,
                        'Guardados', selectedIndex.value, onTap: () {
                      localArticleBloc.add(const GetSavedArticles());
                      handleTabSelection(1);
                    }),
                    _buildAddButton(context, 2, selectedIndex.value,
                        () => handleTabSelection(2)),
                    _buildNavItem(context, 3, Icons.drive_file_rename_outline,
                        'Borradores', selectedIndex.value, onTap: () {
                      draftsCubit.loadDrafts();
                      handleTabSelection(3);
                    }),
                    _buildNavItem(context, 4, Icons.person_outline, 'Cuenta',
                        selectedIndex.value,
                        onTap: () => handleTabSelection(4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPage(int index, GlobalKey<PublishArticlePageState> key,
      VoidCallback onCancel) {
    switch (index) {
      case 0:
        return const DailyNews();
      case 1:
        return const SavedArticles();
      case 2:
        return PublishArticlePage(
          key: key,
          onCancel: onCancel,
        );
      case 3:
        return const DraftsPage();
      case 4:
        return const AccountPage();
      default:
        return const DailyNews();
    }
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon,
      String label, int currentIndex,
      {VoidCallback? onTap}) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(8), // Reduced hit-area padding
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(10), // Tighter visual pill
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: isSelected ? 26 : 24, // Slightly smaller active icon
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(
      BuildContext context, int index, int currentIndex, VoidCallback onTap) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: isSelected ? 30 : 26,
        ),
      ),
    );
  }
}

// Helper mixin or extension not needed if we keep it simple.
// I will insert update the build method to use these helpers, but wait, 
// _buildNavItem needs to call handleTabSelection.
// I'll fix the callback logic in the next replacement chunk.

