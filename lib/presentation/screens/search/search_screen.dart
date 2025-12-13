import 'package:flutter/cupertino.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Search')),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.search,
                size: 64,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Search Screen',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 8),
              const Text(
                'Coming soon...',
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
