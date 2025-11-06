import 'package:flutter/material.dart';
import 'package:hackerton/core/design_system/color.dart';

/// Design System Typography
class HackerTonTypography {
  HackerTonTypography._();

  static const _defaultFontFamily = 'VitroCore';

  static TextStyle MainLarge = TextStyle(
    fontFamily: _defaultFontFamily,
    fontWeight: FontWeight.w900,
    fontSize: 16,
    color: HackerTonColors.black,
  );

  static TextStyle MainMedium = TextStyle(
    fontFamily: _defaultFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: HackerTonColors.white,
  );

  static TextStyle MainSmall = TextStyle(
    fontFamily: _defaultFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: HackerTonColors.grey200,
  );
}
