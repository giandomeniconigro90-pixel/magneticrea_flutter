import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/construction_detail_screen.dart';
import 'screens/guide_screen.dart';
import 'models/construction.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const CatalogScreen(),
    ),
    GoRoute(
      path: '/construction/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ConstructionDetailScreen(constructionId: id);
      },
    ),
    GoRoute(
      path: '/guide/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GuideScreen(constructionId: id);
      },
    ),
  ],
);
