import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.settings,
                size: 64,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Settings Screen',
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
