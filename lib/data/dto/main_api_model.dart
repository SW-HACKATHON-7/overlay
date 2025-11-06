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
