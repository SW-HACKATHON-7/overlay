import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HackerTonIcon {
  HackerTonIcon._();

  static const String _basePath = 'assets/images';

  // SVG 아이콘들
  static Widget bestExcellent({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/10.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget best({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/8.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget blunder({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/1.svg',
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
        '$_basePath/6.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget excellent({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/9.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget good({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/5.svg',
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
        '$_basePath/4.svg',
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
        '$_basePath/2.svg',
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );

  static Widget mistake({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        '$_basePath/3.svg',
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
        '$_basePath/0.svg',
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
