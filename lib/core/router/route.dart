import 'package:go_router/go_router.dart';
import 'package:hackerton/presentation/choosePartner/choose_partner_screen.dart';
import 'package:hackerton/presentation/main/screens/main_screen.dart';
import 'package:hackerton/presentation/verify/verify_screen.dart';
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
    GoRoute(
      path: '/verify',
      name: RouteNames.verify,
      builder: (context, state) => const VerifyScreen(),
    ),
    GoRoute(
      path: '/choose_partner',
      name: RouteNames.choosePartner,
      builder: (context, state) => const ChoosePartnerScreen(),
    ),
  ],
);

class RouteNames {
  static const String splash = 'splash';
  static const String main = 'main';
  static const String verify = 'verify';
  static const String choosePartner = 'choose_partner';
}
