import 'dart:io';
import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:hackerton/data/service/api_service.dart';
import 'package:dio/dio.dart';

/// 대화 복기 분석 서비스
/// 세션 생성, 스크린샷 업로드, 분석 처리, 결과 조회를 담당
class AnalysisService {
  final ApiService _apiService;
  String? _currentSessionId;

  AnalysisService(this._apiService);

  /// 현재 세션 ID 반환
  String? get currentSessionId => _currentSessionId;

  /// 새로운 분석 세션 시작
  Future<String?> createSession() async {
    try {
      final response = await _apiService.createSession();
      _currentSessionId = response.sessionId;
      print('세션 생성 성공: $_currentSessionId');
      return _currentSessionId;
    } catch (e) {
      print('세션 생성 실패: $e');
      return null;
    }
  }

  /// 스크린샷 업로드
  Future<bool> uploadScreenshot(String screenshotPath) async {
    if (_currentSessionId == null) {
      print('세션이 생성되지 않았습니다');
      return false;
    }

    try {
      final file = File(screenshotPath);
      if (!await file.exists()) {
        print('스크린샷 파일이 존재하지 않습니다: $screenshotPath');
        return false;
      }

      final response = await _apiService.uploadScreenshot(_currentSessionId!, file);
      print('스크린샷 업로드 성공: ${response.screenshotId}, 순서: ${response.uploadOrder}');
      return true;
    } catch (e) {
      print('스크린샷 업로드 실패: $e');
      return false;
    }
  }

  /// 여러 스크린샷 일괄 업로드
  Future<int> uploadMultipleScreenshots(List<String> screenshotPaths) async {
    int successCount = 0;
    for (final path in screenshotPaths) {
      final success = await uploadScreenshot(path);
      if (success) successCount++;
    }
    return successCount;
  }

  /// 세션 처리 (OCR + 병합 + AI 분석)
  Future<ProcessResponse?> processSession({
    required String relationship,
    required String relationshipInfo,
  }) async {
    if (_currentSessionId == null) {
      print('세션이 생성되지 않았습니다');
      return null;
    }

    try {
      final response = await _apiService.processSession(
        _currentSessionId!,
        relationship,
        relationshipInfo,
      );
      print('세션 처리 완료: ${response.totalMessages}개 메시지 추출');
      return response;
    } catch (e) {
      print('세션 처리 실패: $e');
      return null;
    }
  }

  /// 전체 메시지 조회
  Future<MessagesResponse?> getMessages() async {
    if (_currentSessionId == null) {
      print('세션이 생성되지 않았습니다');
      return null;
    }

    try {
      final response = await _apiService.getMessages(_currentSessionId!);
      print('메시지 조회 성공: ${response.totalMessages}개');
      return response;
    } catch (e) {
      print('메시지 조회 실패: $e');
      return null;
    }
  }

  /// 현재 화면의 스크린샷으로 분석 결과 조회 (실시간 좌표 업데이트용)
  Future<ViewResponse?> viewByCurrentScreenshot(String screenshotPath) async {
    if (_currentSessionId == null) {
      print('세션이 생성되지 않았습니다');
      return null;
    }

    try {
      final file = File(screenshotPath);
      if (!await file.exists()) {
        print('스크린샷 파일이 존재하지 않습니다: $screenshotPath');
        return null;
      }

      final response = await _apiService.viewByScreenshots(
        _currentSessionId!,
        [file],
      );
      print('화면 분석 성공: ${response.totalMatched}개 메시지 매칭됨');
      return response;
    } catch (e) {
      print('화면 분석 실패: $e');
      return null;
    }
  }

  /// 다음 메시지 제안 가져오기
  Future<PredictNextResponse?> getPredictNextMessages() async {
    if (_currentSessionId == null) {
      print('세션이 생성되지 않았습니다');
      return null;
    }

    try {
      final response = await _apiService.predictNextMessage(_currentSessionId!);
      print('다음 메시지 제안 조회 성공: ${response.suggestions.length}개');
      return response;
    } catch (e) {
      print('다음 메시지 제안 조회 실패: $e');
      return null;
    }
  }

  /// 세션 초기화
  void resetSession() {
    _currentSessionId = null;
    print('세션이 초기화되었습니다');
  }
}

/// 점수에 따른 아이콘 매핑 (0 ~ 10 범위)
String getScoreIcon(double? score) {
  if (score == null) return 'assets/images/0.svg';

  // appropriateness_rating이 0-100 범위로 올 수 있으므로
  // 0-10 범위로 정규화
  final normalizedScore = score > 10 ? (score / 10).round() : score.round();

  // 0-10 범위로 클램핑
  final clampedScore = normalizedScore.clamp(0, 10);

  return 'assets/images/$clampedScore.svg';
}

/// API 서비스 싱글톤 생성 헬퍼
ApiService createApiService() {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // 로깅 인터셉터 추가 (디버깅용)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    requestHeader: true,
    responseHeader: false,
  ));

  return ApiService(dio);
}
