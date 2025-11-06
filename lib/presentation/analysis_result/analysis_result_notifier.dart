import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:hackerton/presentation/analysis_result/analysis_result_state.dart';

class AnalysisResultNotifier extends StateNotifier<AnalysisResultState> {
  AnalysisResultNotifier() : super(const AnalysisResultState());

  // 분석 결과 설정
  void setAnalysisResult({
    required List<MessageDetail> messages,
    required String relationship,
    String? sessionId,
  }) {
    state = state.copyWith(
      messages: messages,
      relationship: relationship,
      sessionId: sessionId,
    );
  }

  // 초기화
  void reset() {
    state = const AnalysisResultState();
  }
}

// Provider
final analysisResultNotifierProvider =
    StateNotifierProvider<AnalysisResultNotifier, AnalysisResultState>((ref) {
  return AnalysisResultNotifier();
});
