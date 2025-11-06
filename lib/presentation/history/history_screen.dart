import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SvgPicture.asset('assets/images/history.svg'),
    );
  }
}
