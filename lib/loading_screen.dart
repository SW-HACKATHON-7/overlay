import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hackerton/core/widget/base_scaffold.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(child: SvgPicture.asset('assets/images/loading_icon.svg')),
    );
  }
}
