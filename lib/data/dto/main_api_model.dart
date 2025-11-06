// lib/api_models.dart
import 'package:json_annotation/json_annotation.dart';

part 'main_api_model.g.dart'; // 코드 생성기가 만들 파일

// 1. 세션 생성 응답
@JsonSerializable()
class SessionResponse {
  @JsonKey(name: "session_id")
  final String sessionId;
  @JsonKey(name: "created_at")
  final String createdAt;

  SessionResponse({required this.sessionId, required this.createdAt});
  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SessionResponseToJson(this);
}

// 2. 스크린샷 업로드 응답
@JsonSerializable()
class UploadResponse {
  @JsonKey(name: "screenshot_id")
  final String screenshotId;
  @JsonKey(name: "upload_order")
  final int uploadOrder;

  UploadResponse({required this.screenshotId, required this.uploadOrder});
  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);
}

// 3. 세션 처리 응답 (Nested Classes 포함)
@JsonSerializable()
class MergeHistoryStep {
  final int step;
  @JsonKey(name: "overlap_found")
  final bool overlapFound;
  @JsonKey(name: "overlap_length")
  final int overlapLength;

  MergeHistoryStep({
    required this.step,
    required this.overlapFound,
    required this.overlapLength,
  });
  factory MergeHistoryStep.fromJson(Map<String, dynamic> json) =>
      _$MergeHistoryStepFromJson(json);
  Map<String, dynamic> toJson() => _$MergeHistoryStepToJson(this);
}

@JsonSerializable()
class MergeInfo {
  @JsonKey(name: "merge_history")
  final List<MergeHistoryStep> mergeHistory;

  MergeInfo({required this.mergeHistory});
  factory MergeInfo.fromJson(Map<String, dynamic> json) =>
      _$MergeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MergeInfoToJson(this);
}

@JsonSerializable()
class ProcessResponse {
  final String status;
  @JsonKey(name: "total_screenshots")
  final int totalScreenshots;
  @JsonKey(name: "total_messages")
  final int totalMessages;
  @JsonKey(name: "external_api_called")
  final bool externalApiCalled;
  @JsonKey(name: "merge_info")
  final MergeInfo mergeInfo;

  ProcessResponse({
    required this.status,
    required this.totalScreenshots,
    required this.totalMessages,
    required this.externalApiCalled,
    required this.mergeInfo,
  });
  factory ProcessResponse.fromJson(Map<String, dynamic> json) =>
      _$ProcessResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessResponseToJson(this);
}

// 4. 메시지 조회 응답 (Nested Classes 포함)
@JsonSerializable()
class Message {
  final String speaker;
  final String text;
  final double? score; // 점수가 없는 메시지가 있을 수 있으므로 nullable

  Message({required this.speaker, required this.text, this.score});
  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class MessagesResponse {
  @JsonKey(name: "total_messages")
  final int totalMessages;
  @JsonKey(name: "total_screenshots")
  final int totalScreenshots;
  final List<Message> messages;

  MessagesResponse({
    required this.totalMessages,
    required this.totalScreenshots,
    required this.messages,
  });
  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$MessagesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessagesResponseToJson(this);
}

// 5. 스크린샷 검색 응답 (Nested Classes 포함)
@JsonSerializable()
class SearchResult {
  final String speaker;
  final String text;

  SearchResult({required this.speaker, required this.text});
  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}

@JsonSerializable()
class SearchResponse {
  final bool matched;
  final String message;
  final List<SearchResult> results;

  SearchResponse({
    required this.matched,
    required this.message,
    required this.results,
  });
  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}

// 6. 스크린샷으로 분석 결과 조회 응답
@JsonSerializable()
class MessageDetail {
  @JsonKey(name: "message_id")
  final String messageId;
  final String text;
  final String speaker;
  final double confidence;
  final MessagePosition position;
  @JsonKey(name: "group_id")
  final int groupId;
  final double? score;
  @JsonKey(name: "emotional_tone")
  final String? emotionalTone;
  @JsonKey(name: "impact_score")
  final double? impactScore;
  @JsonKey(name: "ai_message")
  final String? aiMessage;
  @JsonKey(name: "suggested_alternative")
  final String? suggestedAlternative;

  MessageDetail({
    required this.messageId,
    required this.text,
    required this.speaker,
    required this.confidence,
    required this.position,
    required this.groupId,
    this.score,
    this.emotionalTone,
    this.impactScore,
    this.aiMessage,
    this.suggestedAlternative,
  });
  factory MessageDetail.fromJson(Map<String, dynamic> json) =>
      _$MessageDetailFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDetailToJson(this);
}

@JsonSerializable()
class MessagePosition {
  final double x;
  final double y;
  final double width;
  final double height;

  MessagePosition({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  factory MessagePosition.fromJson(Map<String, dynamic> json) =>
      _$MessagePositionFromJson(json);
  Map<String, dynamic> toJson() => _$MessagePositionToJson(this);
}

@JsonSerializable()
class ViewResponse {
  @JsonKey(name: "session_id")
  final String sessionId;
  final bool matched;
  @JsonKey(name: "total_matched")
  final int totalMatched;
  @JsonKey(name: "total_ocr_extracted")
  final int totalOcrExtracted;
  final List<MessageDetail> messages;

  ViewResponse({
    required this.sessionId,
    required this.matched,
    required this.totalMatched,
    required this.totalOcrExtracted,
    required this.messages,
  });
  factory ViewResponse.fromJson(Map<String, dynamic> json) =>
      _$ViewResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ViewResponseToJson(this);
}

// 7. 다음 대화 예측 응답
@JsonSerializable()
class MessageSuggestion {
  final String style;
  final String text;
  @JsonKey(name: "expected_impact")
  final int expectedImpact;
  final String explanation;

  MessageSuggestion({
    required this.style,
    required this.text,
    required this.expectedImpact,
    required this.explanation,
  });
  factory MessageSuggestion.fromJson(Map<String, dynamic> json) =>
      _$MessageSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$MessageSuggestionToJson(this);
}

@JsonSerializable()
class PredictNextResponse {
  @JsonKey(name: "session_id")
  final String sessionId;
  final String relationship;
  @JsonKey(name: "relationship_info")
  final String relationshipInfo;
  @JsonKey(name: "total_messages")
  final int totalMessages;
  final List<MessageSuggestion> suggestions;

  PredictNextResponse({
    required this.sessionId,
    required this.relationship,
    required this.relationshipInfo,
    required this.totalMessages,
    required this.suggestions,
  });
  factory PredictNextResponse.fromJson(Map<String, dynamic> json) =>
      _$PredictNextResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PredictNextResponseToJson(this);
}

// 8. 대화 시작 응답
@JsonSerializable()
class StartConversationRequest {
  final String relationship;

  StartConversationRequest({required this.relationship});
  factory StartConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$StartConversationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$StartConversationRequestToJson(this);
}

@JsonSerializable()
class StartConversationResponse {
  final String message;
  @JsonKey(name: "thread_id")
  final String threadId;

  StartConversationResponse({
    required this.message,
    required this.threadId,
  });
  factory StartConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$StartConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StartConversationResponseToJson(this);
}

// 9. 대화 이어가기 요청/응답
@JsonSerializable()
class ContinueConversationRequest {
  final String message;
  @JsonKey(name: "thread_id")
  final String threadId;

  ContinueConversationRequest({
    required this.message,
    required this.threadId,
  });
  factory ContinueConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$ContinueConversationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ContinueConversationRequestToJson(this);
}

@JsonSerializable()
class ConversationResponse {
  @JsonKey(name: "emotional_tone")
  final String emotionalTone;
  @JsonKey(name: "appropriateness_rating")
  final int appropriatenessRating;
  @JsonKey(name: "impact_score")
  final int impactScore;
  @JsonKey(name: "review_comment")
  final String reviewComment;
  @JsonKey(name: "suggested_alternative")
  final String suggestedAlternative;

  ConversationResponse({
    required this.emotionalTone,
    required this.appropriatenessRating,
    required this.impactScore,
    required this.reviewComment,
    required this.suggestedAlternative,
  });
  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

@JsonSerializable()
class ContinueConversationResponse {
  final String message;
  final ConversationResponse response;

  ContinueConversationResponse({
    required this.message,
    required this.response,
  });
  factory ContinueConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ContinueConversationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ContinueConversationResponseToJson(this);
}
