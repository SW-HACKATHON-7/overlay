import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? btn;
  final bool resizeToAvoidBottomInset;

  const BaseScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.btn,
    this.resizeToAvoidBottomInset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 40),
          child: body,
        ),
      ),
      bottomNavigationBar: btn,
    );
  }
}
