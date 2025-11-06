import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

enum OverlayState {
  needAnalysis, // 대화 분석이 필요해요
  recording, // 분석 중입니다
  completed, // 분석이 끝났습니다
  analysisResult, // 분석 결과 리스트
}

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  OverlayState currentState = OverlayState.needAnalysis;
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;

  @override
  void initState() {
    super.initState();

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
          final count = message.replaceFirst('SUCCESS:', '');
          print('Auto scroll completed successfully: $count screenshots');

          setState(() {
            currentState = OverlayState.completed;
          });
        } else if (message.startsWith('ERROR:')) {
          final error = message.replaceFirst('ERROR:', '');
          print('Auto scroll failed: $error');

          setState(() {
            currentState = OverlayState.needAnalysis;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_kPortNameOverlay);
    super.dispose();
  }

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

  void _closeOverlay() {
    // 상태 초기화
    setState(() {
      currentState = OverlayState.needAnalysis;
    });
    FlutterOverlayWindow.closeOverlay();
  }

  void _stopAnalysis() {
    // 스크롤 중단 명령 전송
    homePort ??= IsolateNameServer.lookupPortByName(_kPortNameHome);
    homePort?.send('COMMAND:STOP_AUTO_SCROLL');
    print('Sent STOP_AUTO_SCROLL request to main app');

    // 상태 초기화
    setState(() {
      currentState = OverlayState.needAnalysis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverlayContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    switch (currentState) {
      case OverlayState.needAnalysis:
        return _buildNeedAnalysisCard();
      case OverlayState.recording:
        return _buildRecordingCard();
      case OverlayState.completed:
        return _buildCompletedCard();
      case OverlayState.analysisResult:
        return _buildAnalysisResultCard();
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
          Text(
            '대화 분석이 필요해요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '대화 분석을 시작할 부분으로 화면을 이동해 주세요',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                onTap: _startAnalysis,
                child: Center(
                  child: Text(
                    '분석 시작',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'VitroCore',
                    ),
                  ),
                ),
              ),
            ),
          ),
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
          Text(
            '분석 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                onTap: _stopAnalysis,
                child: Center(
                  child: Text(
                    '분석 중단',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'VitroCore',
                    ),
                  ),
                ),
              ),
            ),
          ),
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
          Text(
            '분석이 끝났습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '자세한 분석을 보려면 대화를 클릭해주세요',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                onTap: () {
                  setState(() {
                    currentState = OverlayState.analysisResult;
                  });
                },
                child: Center(
                  child: Text(
                    '답변 주집받기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'VitroCore',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                onTap: _closeOverlay,
                child: Center(
                  child: Text(
                    '복기 종료하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'VitroCore',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 분석 결과 리스트
  Widget _buildAnalysisResultCard() {
    return Expanded(
      child: Container(
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
            _buildAnalysisItem(
              icon: '??',
              iconColor: Color(0xFFFF6B6B),
              title: '불편더',
              description: '네 그래서 어제 올리긴 못했죠',
            ),
            const SizedBox(height: 12),
            _buildAnalysisItem(
              icon: '−',
              iconColor: Color(0xFFD4A574),
              title: '피드백',
              description: '이 답변 이후 분위기가 안 좋아졌어요\n다소 공격적으로 들릴 수 있어요',
            ),
            const SizedBox(height: 12),
            _buildAnalysisItem(
              icon: '!!',
              iconColor: Color(0xFF4CAF50),
              title: '모범 답안',
              description:
                  '"그 부분이 조금 의아했는데, 네 생각을 좀 더 듣고 싶어요"\n라고 말했으면 좋았을 것 같아요',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
                  onTap: _closeOverlay,
                  child: Center(
                    child: Text(
                      '복기 종료하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'VitroCore',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'VitroCore',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontFamily: 'VitroCore',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
