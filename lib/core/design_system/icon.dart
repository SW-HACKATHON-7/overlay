import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HackerTonIcon {
  HackerTonIcon._();

  static const String _basePath = 'assets/images';

  // SVG 아이콘들
  static Widget bestExcellent({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/best_excellent.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget best({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/best.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget blunder({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/blunder.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget chatIcon({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/chat_icon.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget chat({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/chat.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget distinguished({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/distinguished.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget excellent({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/excellent.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget good({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/good.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget heartTalk({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/heart_talk.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget inaccurate({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/inaccurate.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget loadingIcon({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/loading_icon.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget logo({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/logo.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget mainLogo({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/main_logo.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget missedCount({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/missed_count.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget mistake({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/mistake.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget talkIcon({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/talk_icon.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget theory({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/theory.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget uploadIcon({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/upload_icon.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
}
