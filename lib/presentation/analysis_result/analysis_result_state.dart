import 'package:hackerton/data/dto/main_api_model.dart';

class AnalysisResultState {
  final List<MessageDetail> messages;
  final String relationship;
  final String? sessionId;

  const AnalysisResultState({
    this.messages = const [],
    this.relationship = '',
    this.sessionId,
  });

  AnalysisResultState copyWith({
    List<MessageDetail>? messages,
    String? relationship,
    String? sessionId,
  }) {
    return AnalysisResultState(
      messages: messages ?? this.messages,
      relationship: relationship ?? this.relationship,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
