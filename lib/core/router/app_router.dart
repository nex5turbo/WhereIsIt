import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/spaces/space_list_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'space/:id',
            name: 'space_detail',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return SpaceListScreen(parentId: id);
            },
          ),
        ],
      ),
    ],
  );
}
