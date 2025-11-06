import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/route.dart';
import 'presentation/overlay/overlay_widget_new.dart';
import 'services/screenshot_service.dart';

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();

  // 오버레이 포트가 이미 등록되어 있으면 제거
  IsolateNameServer.removePortNameMapping('OVERLAY');

  runApp(const OverlayWidgetNew());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _kPortNameHome = 'UI';
  static const String _kPortNameOverlay = 'OVERLAY';
  final _receivePort = ReceivePort();
  SendPort? overlayPort;

  @override
  void initState() {
    super.initState();

    // 메인 앱 포트 등록
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameHome,
    );
    print('Port registration result: $res');

    // 오버레이로부터 메시지 수신
    _receivePort.listen((message) async {
      print('Main app received message from overlay: $message');

      if (message == 'COMMAND:START_AUTO_SCROLL') {
        print('Starting auto scroll from main app...');

        try {
          // 권한 체크
          final hasScreenCapture = await ScreenshotService.hasPermission();
          final hasAccessibility = await ScreenshotService.checkAccessibilityPermission();

          print('Permissions - ScreenCapture: $hasScreenCapture, Accessibility: $hasAccessibility');

          if (!hasScreenCapture || !hasAccessibility) {
            overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
            overlayPort?.send('ERROR:Permissions not granted');
            return;
          }

          // 자동 스크롤 실행
          final screenshots = await ScreenshotService.startAutoScroll();
          print('Auto scroll completed: ${screenshots.length} screenshots');

          // 결과를 오버레이로 전송 (스크린샷 경로 포함)
          overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
          overlayPort?.send('SUCCESS:${screenshots.join(',')}');
        } catch (e) {
          print('Error during auto scroll: $e');
          overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
          overlayPort?.send('ERROR:$e');
        }
      } else if (message == 'COMMAND:STOP_AUTO_SCROLL') {
        print('Stopping auto scroll from main app...');
        await ScreenshotService.stopAutoScroll();

        // 오버레이에 중단 알림
        overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
        overlayPort?.send('STOPPED');
      }
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_kPortNameHome);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
