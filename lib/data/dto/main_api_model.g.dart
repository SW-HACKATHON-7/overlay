// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    SessionResponse(
      sessionId: json['session_id'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SessionResponseToJson(SessionResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'created_at': instance.createdAt,
    };

UploadResponse _$UploadResponseFromJson(Map<String, dynamic> json) =>
    UploadResponse(
      screenshotId: json['screenshot_id'] as String,
      uploadOrder: (json['upload_order'] as num).toInt(),
    );

Map<String, dynamic> _$UploadResponseToJson(UploadResponse instance) =>
    <String, dynamic>{
      'screenshot_id': instance.screenshotId,
      'upload_order': instance.uploadOrder,
    };

MergeHistoryStep _$MergeHistoryStepFromJson(Map<String, dynamic> json) =>
    MergeHistoryStep(
      step: (json['step'] as num).toInt(),
      overlapFound: json['overlap_found'] as bool,
      overlapLength: (json['overlap_length'] as num).toInt(),
    );

Map<String, dynamic> _$MergeHistoryStepToJson(MergeHistoryStep instance) =>
    <String, dynamic>{
      'step': instance.step,
      'overlap_found': instance.overlapFound,
      'overlap_length': instance.overlapLength,
    };

MergeInfo _$MergeInfoFromJson(Map<String, dynamic> json) => MergeInfo(
      mergeHistory: (json['merge_history'] as List<dynamic>)
          .map((e) => MergeHistoryStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MergeInfoToJson(MergeInfo instance) => <String, dynamic>{
      'merge_history': instance.mergeHistory,
    };

ProcessResponse _$ProcessResponseFromJson(Map<String, dynamic> json) =>
    ProcessResponse(
      status: json['status'] as String,
      totalScreenshots: (json['total_screenshots'] as num).toInt(),
      totalMessages: (json['total_messages'] as num).toInt(),
      externalApiCalled: json['external_api_called'] as bool,
      mergeInfo: MergeInfo.fromJson(json['merge_info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProcessResponseToJson(ProcessResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'total_screenshots': instance.totalScreenshots,
      'total_messages': instance.totalMessages,
      'external_api_called': instance.externalApiCalled,
      'merge_info': instance.mergeInfo,
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      score: (json['score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'speaker': instance.speaker,
      'text': instance.text,
      'score': instance.score,
    };

MessagesResponse _$MessagesResponseFromJson(Map<String, dynamic> json) =>
    MessagesResponse(
      totalMessages: (json['total_messages'] as num).toInt(),
      totalScreenshots: (json['total_screenshots'] as num).toInt(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MessagesResponseToJson(MessagesResponse instance) =>
    <String, dynamic>{
      'total_messages': instance.totalMessages,
      'total_screenshots': instance.totalScreenshots,
      'messages': instance.messages,
    };

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'speaker': instance.speaker,
      'text': instance.text,
    };

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    SearchResponse(
      matched: json['matched'] as bool,
      message: json['message'] as String,
      results: (json['results'] as List<dynamic>)
          .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'matched': instance.matched,
      'message': instance.message,
      'results': instance.results,
    };
