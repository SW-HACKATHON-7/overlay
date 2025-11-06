import 'package:go_router/go_router.dart';
import 'package:hackerton/presentation/analysis_result/analysis_result_screen.dart';
import 'package:hackerton/presentation/choosePartner/choose_partner_screen.dart';
import 'package:hackerton/presentation/main/screens/main_screen.dart';
import 'package:hackerton/presentation/mode_selection/mode_selection_screen.dart';
import 'package:hackerton/presentation/quiz/quiz_chat_screen.dart';
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
      path: '/mode_selection',
      name: RouteNames.modeSelection,
      builder: (context, state) => const ModeSelectionScreen(),
    ),
    GoRoute(
      path: '/main',
      name: RouteNames.main,
      builder: (context, state) => MainScreen(),
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
    GoRoute(
      path: '/quiz',
      name: RouteNames.quiz,
      builder: (context, state) {
        final relationship = state.extra as String?;
        return QuizChatScreen(relationship: relationship ?? '직장 상사');
      },
    ),
    GoRoute(
      path: '/analysis_result',
      name: RouteNames.analysisResult,
      builder: (context, state) => const AnalysisResultScreen(),
    ),
  ],
);

class RouteNames {
  static const String splash = 'splash';
  static const String modeSelection = 'mode_selection';
  static const String main = 'main';
  static const String verify = 'verify';
  static const String choosePartner = 'choose_partner';
  static const String quiz = 'quiz';
  static const String analysisResult = 'analysisResult';
}
