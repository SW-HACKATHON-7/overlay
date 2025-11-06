import 'package:go_router/go_router.dart';
import 'package:hackerton/presentation/main/screens/main_screen.dart';
import 'package:hackerton/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/main',
      name: RouteNames.main,
      builder: (context, state) => const MainScreen(),
    ),
  ],
);

class RouteNames {
  static const String splash = 'splash';
  static const String main = 'main';
}
