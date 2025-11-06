import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/route.dart';
import 'data/dto/main_api_model.dart';
import 'presentation/analysis_result/analysis_result_notifier.dart';
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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static const String _kPortNameHome = 'UI';
  static const String _kPortNameOverlay = 'OVERLAY';
  final _receivePort = ReceivePort();
  SendPort? overlayPort;
  final _routerKey = GlobalKey<NavigatorState>();
  bool _shouldNavigateToAnalysisResult = false;

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
      } else if (message == 'COMMAND:TAKE_SCREENSHOT') {
        print('Taking screenshot for overlay...');

        try {
          // 단일 스크린샷 촬영
          final screenshotPath = await ScreenshotService.takeScreenshot();

          if (screenshotPath != null) {
            print('Screenshot taken: $screenshotPath');
            // 스크린샷 경로를 오버레이로 전송
            overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
            overlayPort?.send('SCREENSHOT:$screenshotPath');
          } else {
            print('Failed to take screenshot');
          }
        } catch (e) {
          print('Error taking screenshot: $e');
        }
      } else if (message is String && message.startsWith('COMMAND:SHOW_MARKERS:')) {
        print('Showing markers from main app...');

        try {
          // Extract JSON from command
          final markersJson = message.substring('COMMAND:SHOW_MARKERS:'.length);
          print('Markers JSON: $markersJson');

          // Call native method to show markers
          final success = await ScreenshotService.showMarkers(markersJson);
          print('Native markers displayed: $success');

          // Send success response back to overlay
          overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
          overlayPort?.send('MARKERS_SHOWN:$success');
        } catch (e) {
          print('Error showing markers: $e');
          overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
          overlayPort?.send('MARKERS_SHOWN:false');
        }
      } else if (message == 'COMMAND:CLEAR_MARKERS') {
        print('Clearing markers from main app...');

        try {
          await ScreenshotService.clearMarkers();
          print('Markers cleared');

          overlayPort ??= IsolateNameServer.lookupPortByName(_kPortNameOverlay);
          overlayPort?.send('MARKERS_CLEARED');
        } catch (e) {
          print('Error clearing markers: $e');
        }
      } else if (message is String && message.startsWith('{')) {
        // JSON 데이터 (분석 결과)
        print('=== JSON 메시지 수신 ===');
        print('메시지 길이: ${message.length}');
        print('메시지 시작: ${message.substring(0, message.length > 100 ? 100 : message.length)}...');
        try {
          final data = jsonDecode(message) as Map<String, dynamic>;
          print('JSON 파싱 성공');
          print('Action: ${data['action']}');
          if (data['action'] == 'ANALYSIS_COMPLETE') {
            print('분석 완료 액션 확인됨 - 처리 시작...');
            _handleAnalysisResult(data);
          }
        } catch (e) {
          print('❌ Error parsing analysis result: $e');
          print('Stack trace: ${StackTrace.current}');
        }
      }
    });
  }

  void _handleAnalysisResult(Map<String, dynamic> data) {
    try {
      print('_handleAnalysisResult 시작');
      final sessionId = data['sessionId'] as String?;
      final relationship = data['relationship'] as String? ?? 'FRIEND';
      final messagesData = data['messages'] as List<dynamic>;

      print('Session ID: $sessionId');
      print('Relationship: $relationship');
      print('Messages count: ${messagesData.length}');

      // MessageDetail 리스트로 변환
      final messages = messagesData.map((msgData) {
        final msgMap = msgData as Map<String, dynamic>;
        final posMap = msgMap['position'] as Map<String, dynamic>;

        return MessageDetail(
          messageId: msgMap['messageId'] as String,
          text: msgMap['text'] as String,
          speaker: msgMap['speaker'] as String,
          confidence: (msgMap['confidence'] as num).toDouble(),
          position: MessagePosition(
            x: (posMap['x'] as num).toDouble(),
            y: (posMap['y'] as num).toDouble(),
            width: (posMap['width'] as num).toDouble(),
            height: (posMap['height'] as num).toDouble(),
          ),
          groupId: msgMap['groupId'] as int,
          score: msgMap['score'] != null ? (msgMap['score'] as num).toDouble() : null,
          emotionalTone: msgMap['emotionalTone'] as String?,
          impactScore: msgMap['impactScore'] != null ? (msgMap['impactScore'] as num).toDouble() : null,
          aiMessage: msgMap['aiMessage'] as String?,
          suggestedAlternative: msgMap['suggestedAlternative'] as String?,
        );
      }).toList();

      print('메시지 변환 완료: ${messages.length}개');

      // Provider에 저장
      print('Provider에 저장 시작...');
      ref.read(analysisResultNotifierProvider.notifier).setAnalysisResult(
            messages: messages,
            relationship: relationship,
            sessionId: sessionId,
          );
      print('Provider 저장 완료');

      // 분석 결과 화면으로 이동 (setState로 rebuild 트리거)
      print('화면 이동 플래그 설정...');
      setState(() {
        _shouldNavigateToAnalysisResult = true;
      });
      print('setState 호출 완료 - rebuild 예정');

      print('✓ 분석 결과 저장 및 화면 이동 플래그 설정 완료');
    } catch (e, stackTrace) {
      print('❌ Error handling analysis result: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_kPortNameHome);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 분석 결과 화면으로 네비게이션
    if (_shouldNavigateToAnalysisResult) {
      print('build: _shouldNavigateToAnalysisResult가 true임 - 네비게이션 스케줄링');
      _shouldNavigateToAnalysisResult = false;

      // 메인 화면으로 먼저 이동 후, 그 화면에서 분석 결과로 자동 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('PostFrameCallback 실행');

        // 메인 화면으로 이동
        Future.delayed(const Duration(milliseconds: 100), () {
          print('메인 화면으로 이동 시도...');
          try {
            router.go('/main');
            print('✓ 메인 화면으로 이동 완료');
          } catch (e) {
            print('❌ 메인 화면 이동 에러: $e');
          }
        });

        // 메인 화면 도착 후 분석 결과 화면으로 이동
        Future.delayed(const Duration(milliseconds: 800), () {
          print('분석 결과 화면으로 이동 시도...');
          try {
            router.push('/analysis_result');
            print('✓ 분석 결과 화면으로 이동 완료');
          } catch (e) {
            print('❌ 분석 결과 화면 이동 에러: $e');
          }
        });
      });
    }

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
