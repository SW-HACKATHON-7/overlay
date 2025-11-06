import 'dart:async';
import 'package:flutter/services.dart';

class ScreenshotService {
  static const MethodChannel _channel = MethodChannel('com.example.overlay/screenshot');

  /// 스크린샷 권한 요청
  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermission');
      return result;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  /// 스크린샷 촬영 (MediaProjection 사용)
  static Future<String?> takeScreenshot() async {
    try {
      final String? path = await _channel.invokeMethod('takeScreenshot');
      return path;
    } catch (e) {
      print('Error taking screenshot: $e');
      return null;
    }
  }

  /// 스크린샷 권한이 있는지 확인
  static Future<bool> hasPermission() async {
    try {
      final bool result = await _channel.invokeMethod('hasPermission');
      return result;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  /// MediaProjection 서비스 중지
  static Future<void> stopCapture() async {
    try {
      await _channel.invokeMethod('stopCapture');
    } catch (e) {
      print('Error stopping capture: $e');
    }
  }

  /// Accessibility Service 권한 확인
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkAccessibilityPermission');
      return result;
    } catch (e) {
      print('Error checking accessibility permission: $e');
      return false;
    }
  }

  /// Accessibility Service 권한 요청 (설정 화면 열기)
  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      print('Error requesting accessibility permission: $e');
    }
  }

  /// 자동 스크롤 + 연속 스크린샷 시작
  static Future<List<String>> startAutoScroll() async {
    try {
      final dynamic result = await _channel.invokeMethod('startAutoScroll');
      if (result is List) {
        return result.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error starting auto scroll: $e');
      return [];
    }
  }

  /// 자동 스크롤 중지
  static Future<void> stopAutoScroll() async {
    try {
      await _channel.invokeMethod('stopAutoScroll');
    } catch (e) {
      print('Error stopping auto scroll: $e');
    }
  }

  /// 앱을 백그라운드로 보내기 (시스템 홈 화면으로 이동)
  static Future<void> moveToBackground() async {
    try {
      await _channel.invokeMethod('moveToBackground');
    } catch (e) {
      print('Error moving to background: $e');
    }
  }
}
