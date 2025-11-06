import 'package:flutter/rendering.dart';

class HackerTonColors {
  HackerTonColors._();

  static const red = Color(0XFFF33259);
  static const orange200 = Color(0xFFFF5252);
  static const orange = Color(0xFFFF6200);
  static const pink = Color(0xFFFF008C);
  static const grey200 = Color(0xFF898989);
  static const grey = Color(0xFF9E9DA3);
  static const white = Color(0xFFFAFAFA);
  static const black = Color(0xFF000000);
}

class HackerTonGradients {
  HackerTonGradients._();

  static const orangeToPink = LinearGradient(
    colors: [Color(0xFFFF0000), Color(0xFFFF00D9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
