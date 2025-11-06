import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:hackerton/services/analysis_service.dart';
import 'package:hackerton/services/screenshot_service.dart';

enum OverlayState {
  needAnalysis, // 대화 분석이 필요해요
  recording, // 분석 중입니다
  completed, // 분석이 끝났습니다
  showingMarkers, // 마커를 화면에 표시 중
}

class OverlayWidgetNew extends StatefulWidget {
  const OverlayWidgetNew({super.key});

  @override
  State<OverlayWidgetNew> createState() => _OverlayWidgetNewState();
}

class _OverlayWidgetNewState extends State<OverlayWidgetNew> {
  OverlayState currentState = OverlayState.needAnalysis;
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;

  late AnalysisService _analysisService;
  List<MessageDetail> _currentMessages = [];
  Timer? _screenCheckTimer;
  String? _lastScreenshotPath;

  @override
  void initState() {
    super.initState();

    // 분석 서비스 초기화
    _analysisService = AnalysisService(createApiService());

    // 오버레이 포트 등록
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameOverlay,
    );
    print('Overlay port registration result: $res');

    // 메인 앱으로부터 메시지 수신
    _receivePort.listen((message) {
      print('Overlay received message from main app: $message');

      if (message is String) {
        if (message.startsWith('SUCCESS:')) {
          _handleAnalysisComplete(message);
        } else if (message.startsWith('ERROR:')) {
          final error = message.replaceFirst('ERROR:', '');
          print('Auto scroll failed: $error');
          setState(() {
            currentState = OverlayState.needAnalysis;
          });
        } else if (message.startsWith('STOPPED')) {
          setState(() {
            currentState = OverlayState.needAnalysis;
          });
        }
      } else if (message is Map) {
        // 세션 정보 받기
        if (message['action'] == 'SESSION_CREATED') {
          print('Session created: ${message['sessionId']}');
        }
      }
    });
  }

  @override
  void dispose() {
    _screenCheckTimer?.cancel();
    IsolateNameServer.removePortNameMapping(_kPortNameOverlay);
    super.dispose();
  }

  /// 분석 완료 처리
  Future<void> _handleAnalysisComplete(String message) async {
    final screenshotPaths = message
        .replaceFirst('SUCCESS:', '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();

    print('Analysis complete with ${screenshotPaths.length} screenshots');

    setState(() {
      currentState = OverlayState.completed;
    });

    // 스크린샷 업로드 및 분석 처리
    if (screenshotPaths.isNotEmpty) {
      await _processScreenshots(screenshotPaths);
    }
  }

  /// 스크린샷 업로드 및 분석 처리
  Future<void> _processScreenshots(List<String> paths) async {
    try {
      // 1. 세션 생성 (아직 없으면)
      if (_analysisService.currentSessionId == null) {
        final sessionId = await _analysisService.createSession();
        if (sessionId == null) {
          print('Failed to create session');
          return;
        }
      }

      // 2. 스크린샷 업로드
      final uploadCount = await _analysisService.uploadMultipleScreenshots(paths);
      print('Uploaded $uploadCount screenshots');

      // 3. 세션 처리 (관계 정보는 하드코딩 - 실제로는 사용자 입력받아야 함)
      final processResponse = await _analysisService.processSession(
        relationship: 'FRIEND',
        relationshipInfo: '친한 친구',
      );

      if (processResponse != null) {
        print('Processing completed: ${processResponse.totalMessages} messages');

        // 4. 첫 화면의 마커 표시를 위해 현재 스크린샷 촬영
        await _showMarkersForCurrentScreen();
      }
    } catch (e) {
      print('Error processing screenshots: $e');
    }
  }

  /// 현재 화면의 마커 표시
  Future<void> _showMarkersForCurrentScreen() async {
    try {
      // 현재 화면 스크린샷 촬영
      final screenshotPath = await ScreenshotService.takeScreenshot();
      if (screenshotPath == null) {
        print('Failed to take screenshot for markers');
        return;
      }

      _lastScreenshotPath = screenshotPath;

      // 현재 화면의 메시지 조회
      final viewResponse =
          await _analysisService.viewByCurrentScreenshot(screenshotPath);

      if (viewResponse != null && viewResponse.messages.isNotEmpty) {
        setState(() {
          _currentMessages = viewResponse.messages;
          currentState = OverlayState.showingMarkers;
        });

        // 주기적으로 화면 변경 확인 시작
        _startScreenChangeDetection();
      }
    } catch (e) {
      print('Error showing markers: $e');
    }
  }

  /// 화면 변경 감지 시작
  void _startScreenChangeDetection() {
    _screenCheckTimer?.cancel();
    _screenCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _checkAndUpdateMarkers();
    });
  }

  /// 화면 변경 확인 및 마커 업데이트
  Future<void> _checkAndUpdateMarkers() async {
    try {
      // 새로운 스크린샷 촬영
      final newScreenshot = await ScreenshotService.takeScreenshot();
      if (newScreenshot == null) return;

      // 이전 스크린샷과 다른지 확인 (간단하게 파일명으로 확인)
      if (newScreenshot == _lastScreenshotPath) return;

      _lastScreenshotPath = newScreenshot;

      // 새로운 화면의 메시지 조회
      final viewResponse =
          await _analysisService.viewByCurrentScreenshot(newScreenshot);

      if (viewResponse != null && viewResponse.messages.isNotEmpty) {
        setState(() {
          _currentMessages = viewResponse.messages;
        });
        print('Markers updated: ${viewResponse.messages.length} messages');
      }
    } catch (e) {
      print('Error updating markers: $e');
    }
  }

  /// 분석 시작
  Future<void> _startAnalysis() async {
    print('=== _startAnalysis started ===');

    setState(() {
      currentState = OverlayState.recording;
    });

    // 메인 앱에 자동 스크롤 시작 요청
    homePort ??= IsolateNameServer.lookupPortByName(_kPortNameHome);
    homePort?.send('COMMAND:START_AUTO_SCROLL');
    print('Sent START_AUTO_SCROLL request to main app');
  }

  /// 분석 중단
  void _stopAnalysis() {
    _screenCheckTimer?.cancel();
    homePort ??= IsolateNameServer.lookupPortByName(_kPortNameHome);
    homePort?.send('COMMAND:STOP_AUTO_SCROLL');
    print('Sent STOP_AUTO_SCROLL request to main app');

    setState(() {
      currentState = OverlayState.needAnalysis;
      _currentMessages = [];
    });
  }

  /// 오버레이 닫기
  void _closeOverlay() {
    _screenCheckTimer?.cancel();
    _analysisService.resetSession();
    setState(() {
      currentState = OverlayState.needAnalysis;
      _currentMessages = [];
    });
    FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 마커 표시
            if (currentState == OverlayState.showingMarkers)
              ..._buildMarkers(),
            // 컨트롤 카드
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: _buildOverlayContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 마커 위젯 생성
  List<Widget> _buildMarkers() {
    return _currentMessages
        .where((msg) => msg.speaker == 'user' && msg.score != null)
        .map((msg) {
      final icon = getScoreIcon(msg.score);
      return Positioned(
        left: msg.position.x - 20, // 아이콘 크기 보정
        top: msg.position.y - 20,
        child: GestureDetector(
          onTap: () => _showMessageDetail(msg),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(
              icon,
              width: 40,
              height: 40,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// 메시지 상세 정보 표시
  void _showMessageDetail(MessageDetail message) {
    // TODO: 모달이나 상세 정보 표시
    print('Message tapped: ${message.text}');
    print('Score: ${message.score}');
    print('AI Feedback: ${message.aiMessage}');
    print('Suggested: ${message.suggestedAlternative}');
  }

  Widget _buildOverlayContent() {
    switch (currentState) {
      case OverlayState.needAnalysis:
        return _buildNeedAnalysisCard();
      case OverlayState.recording:
        return _buildRecordingCard();
      case OverlayState.completed:
        return _buildCompletedCard();
      case OverlayState.showingMarkers:
        return _buildShowingMarkersCard();
    }
  }

  // 대화 분석이 필요해요
  Widget _buildNeedAnalysisCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대화 분석이 필요해요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '대화 분석을 시작할 부분으로 화면을 이동해 주세요',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 20),
          _buildGradientButton('분석 시작', _startAnalysis),
        ],
      ),
    );
  }

  // 분석 중입니다
  Widget _buildRecordingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '분석 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 12),
          _buildGradientButton('분석 중단', _stopAnalysis, height: 48),
        ],
      ),
    );
  }

  // 분석이 끝났습니다
  Widget _buildCompletedCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분석이 끝났습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '대화 내용을 확인하세요',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 20),
          _buildGradientButton('대화 확인하기', _showMarkersForCurrentScreen),
          const SizedBox(height: 12),
          _buildGradientButton('복기 종료하기', _closeOverlay),
        ],
      ),
    );
  }

  // 마커를 표시하는 중
  Widget _buildShowingMarkersCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '분석 중',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_currentMessages.where((m) => m.speaker == 'user').length}개 메시지',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontFamily: 'VitroCore',
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _closeOverlay,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap, {double height = 52}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF3D9A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'VitroCore',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
