import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WhereIsItApp(),
    ),
  );
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
