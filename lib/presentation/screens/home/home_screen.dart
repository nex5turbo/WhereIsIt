import 'package:flutter/cupertino.dart';
import '../spaces/space_list_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const SpaceListScreen(parentId: null);
          case 1:
            return const SearchScreen();
          case 2:
            return const SettingsScreen();
          default:
            return const SpaceListScreen(parentId: null);
        }
      },
    );
  }
}
