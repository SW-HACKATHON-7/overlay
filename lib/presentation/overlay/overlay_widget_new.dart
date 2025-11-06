import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:hackerton/services/analysis_service.dart';
import 'package:hackerton/services/screenshot_service.dart';

enum OverlayState {
  needAnalysis, // 대화 분석이 필요해요
  recording, // 스크롤 중
  processing, // 서버 처리 중 (OCR + AI 분석)
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
    IsolateNameServer.removePortNameMapping(_kPortNameOverlay);
    super.dispose();
  }

  /// 분석 결과를 메인 앱으로 전달
  void _sendAnalysisResultToMainApp(ViewResponse viewResponse) {
    print('=== _sendAnalysisResultToMainApp 시작 ===');
    print('전달할 메시지 수: ${viewResponse.messages.length}');

    final resultData = {
      'action': 'ANALYSIS_COMPLETE',
      'sessionId': _analysisService.currentSessionId,
      'relationship': 'FRIEND', // TODO: 실제 관계 타입
      'messages': viewResponse.messages.map((msg) {
        return {
          'messageId': msg.messageId,
          'text': msg.text,
          'speaker': msg.speaker,
          'confidence': msg.confidence,
          'position': {
            'x': msg.position.x,
            'y': msg.position.y,
            'width': msg.position.width,
            'height': msg.position.height,
          },
          'groupId': msg.groupId,
          'score': msg.score,
          'emotionalTone': msg.emotionalTone,
          'impactScore': msg.impactScore,
          'aiMessage': msg.aiMessage,
          'suggestedAlternative': msg.suggestedAlternative,
        };
      }).toList(),
    };

    final jsonString = jsonEncode(resultData);
    print('JSON 문자열 길이: ${jsonString.length}');
    print('JSON 시작: ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}...');

    homePort ??= IsolateNameServer.lookupPortByName(_kPortNameHome);
    print('HomePort 조회: ${homePort != null ? "성공" : "실패"}');

    if (homePort != null) {
      homePort!.send(jsonString);
      print('✓ JSON 데이터 전송 완료: ${viewResponse.messages.length}개 메시지');
    } else {
      print('❌ HomePort가 null입니다 - 메시지 전송 실패');
    }
  }


  /// 분석 완료 처리 (스크롤 종료 후 자동으로 서버 분석)
  Future<void> _handleAnalysisComplete(String message) async {
    final screenshotPaths = message
        .replaceFirst('SUCCESS:', '')
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList();

    print('Analysis complete with ${screenshotPaths.length} screenshots');
    print('자동으로 서버 분석 시작...');

    // 스크린샷 업로드 및 분석 처리 (완료될 때까지 대기)
    if (screenshotPaths.isNotEmpty) {
      await _processScreenshots(screenshotPaths);
    }
  }

  /// 스크린샷 업로드 및 분석 처리
  Future<void> _processScreenshots(List<String> paths) async {
    try {
      // 처리 중 상태로 전환
      setState(() {
        currentState = OverlayState.processing;
      });

      // 1. 세션 생성 (아직 없으면)
      if (_analysisService.currentSessionId == null) {
        final sessionId = await _analysisService.createSession();
        if (sessionId == null) {
          print('세션 생성 실패');
          setState(() {
            currentState = OverlayState.needAnalysis;
          });
          return;
        }
        print('✓ 세션 생성 완료: $sessionId');
      }

      // 2. 스크린샷 업로드
      print('스크린샷 업로드 중...');
      final uploadCount = await _analysisService.uploadMultipleScreenshots(paths);
      print('✓ 업로드 완료: $uploadCount개');

      // 3. 세션 처리 (OCR + 병합 + AI 분석) - 완료될 때까지 대기
      print('서버 처리 중 (OCR + 병합 + AI 분석)...');
      final processResponse = await _analysisService.processSession(
        relationship: 'FRIEND',
        relationshipInfo: '친한 친구',
      );

      if (processResponse == null) {
        print('세션 처리 실패');
        setState(() {
          currentState = OverlayState.needAnalysis;
        });
        return;
      }

      print('✓ 세션 처리 완료: ${processResponse.totalMessages}개 메시지');

      // 4. 상세 분석 결과 조회 (마지막 스크린샷으로 view 호출)
      print('상세 분석 결과 조회 중...');
      print('마지막 스크린샷 경로: ${paths.last}');
      final viewResponse = await _analysisService.viewByCurrentScreenshot(paths.last);

      if (viewResponse == null || viewResponse.messages.isEmpty) {
        print('⚠️ 상세 분석 결과 조회 실패 또는 메시지 없음');
        print('ViewResponse null: ${viewResponse == null}');
        if (viewResponse != null) {
          print('Messages empty: ${viewResponse.messages.isEmpty}');
        }
        setState(() {
          currentState = OverlayState.needAnalysis;
        });
        return;
      }

      print('✓ 상세 결과 조회 완료: ${viewResponse.messages.length}개 메시지');
      print('메시지 상세:');
      for (var msg in viewResponse.messages) {
        print('  - ${msg.speaker}: ${msg.text.substring(0, msg.text.length > 30 ? 30 : msg.text.length)}... (score: ${msg.score})');
      }

      // 5. 분석 완료 - 메인 앱으로 데이터 전달
      print('메인 앱으로 분석 결과 전달 중...');
      _sendAnalysisResultToMainApp(viewResponse);
      print('✓ 메인 앱으로 데이터 전송 완료');

      // 메시지 전달을 위해 충분히 대기 후 오버레이 닫기
      print('오버레이 닫기 전 대기 중...');
      await Future.delayed(const Duration(seconds: 2));
      print('오버레이 닫기 시작');
      FlutterOverlayWindow.closeOverlay();
    } catch (e) {
      print('Error processing screenshots: $e');
      setState(() {
        currentState = OverlayState.needAnalysis;
      });
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
    homePort ??= IsolateNameServer.lookupPortByName(_kPortNameHome);
    homePort?.send('COMMAND:STOP_AUTO_SCROLL');
    print('Sent STOP_AUTO_SCROLL request to main app');

    setState(() {
      currentState = OverlayState.needAnalysis;
    });
  }

  /// 오버레이 닫기
  void _closeOverlay() {
    _analysisService.resetSession();

    setState(() {
      currentState = OverlayState.needAnalysis;
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


  Widget _buildOverlayContent() {
    switch (currentState) {
      case OverlayState.needAnalysis:
        return _buildNeedAnalysisCard();
      case OverlayState.recording:
        return _buildRecordingCard();
      case OverlayState.processing:
        return _buildProcessingCard();
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

  // 스크롤 중
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
            '스크롤 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 12),
          _buildGradientButton('중단', _stopAnalysis, height: 48),
        ],
      ),
    );
  }

  // 서버 처리 중 (OCR + AI 분석)
  Widget _buildProcessingCard() {
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
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            '서버 처리 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'VitroCore',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'OCR + AI 분석 중입니다',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              fontFamily: 'VitroCore',
            ),
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
