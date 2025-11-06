import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          context.go('/verify');
        }
      });
      return null;
    }, const []);

    return BaseScaffold(
      body: Center(child: SvgPicture.asset('assets/images/logo.svg')),
    );
  }
}
