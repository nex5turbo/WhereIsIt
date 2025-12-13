import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: WhereIsItApp()));
}

class WhereIsItApp extends ConsumerWidget {
  const WhereIsItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Where is it!',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
