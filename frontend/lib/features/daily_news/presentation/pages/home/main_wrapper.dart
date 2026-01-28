import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../articles/presentation/bloc/publish_article_bloc.dart';
import '../../../../articles/presentation/pages/publish_article_page.dart';
import '../../../../../injection_container.dart';
import 'daily_news.dart';

class MainWrapper extends HookWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: selectedIndex.value,
        children: [
          // 0. Home
          const DailyNews(),
          // 1. Saved (Placeholder)
          const _PlaceholderScreen(
              title: 'Guardados', icon: Icons.bookmark_border),
          // 2. New Article (Publish)
          BlocProvider(
            create: (_) => sl<PublishArticleBloc>(),
            child: PublishArticlePage(
              onCancel: () => selectedIndex.value = 0,
            ),
          ),
          // 3. Drafts (Placeholder)
          const _PlaceholderScreen(
              title: 'Borradores', icon: Icons.drafts_outlined),
          // 4. Account (Placeholder)
          const _PlaceholderScreen(title: 'Cuenta', icon: Icons.person_outline),
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
          onTap: (index) => selectedIndex.value = index,
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
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Próximamente',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 18,
                fontFamily: 'Butler',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
