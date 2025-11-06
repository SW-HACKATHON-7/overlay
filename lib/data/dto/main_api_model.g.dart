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

MessageDetail _$MessageDetailFromJson(Map<String, dynamic> json) =>
    MessageDetail(
      messageId: json['message_id'] as String,
      text: json['text'] as String,
      speaker: json['speaker'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      position:
          MessagePosition.fromJson(json['position'] as Map<String, dynamic>),
      groupId: (json['group_id'] as num).toInt(),
      score: (json['score'] as num?)?.toDouble(),
      emotionalTone: json['emotional_tone'] as String?,
      impactScore: (json['impact_score'] as num?)?.toDouble(),
      aiMessage: json['ai_message'] as String?,
      suggestedAlternative: json['suggested_alternative'] as String?,
    );

Map<String, dynamic> _$MessageDetailToJson(MessageDetail instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'text': instance.text,
      'speaker': instance.speaker,
      'confidence': instance.confidence,
      'position': instance.position,
      'group_id': instance.groupId,
      'score': instance.score,
      'emotional_tone': instance.emotionalTone,
      'impact_score': instance.impactScore,
      'ai_message': instance.aiMessage,
      'suggested_alternative': instance.suggestedAlternative,
    };

MessagePosition _$MessagePositionFromJson(Map<String, dynamic> json) =>
    MessagePosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$MessagePositionToJson(MessagePosition instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

ViewResponse _$ViewResponseFromJson(Map<String, dynamic> json) => ViewResponse(
      sessionId: json['session_id'] as String,
      matched: json['matched'] as bool,
      totalMatched: (json['total_matched'] as num).toInt(),
      totalOcrExtracted: (json['total_ocr_extracted'] as num).toInt(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ViewResponseToJson(ViewResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'matched': instance.matched,
      'total_matched': instance.totalMatched,
      'total_ocr_extracted': instance.totalOcrExtracted,
      'messages': instance.messages,
    };

MessageSuggestion _$MessageSuggestionFromJson(Map<String, dynamic> json) =>
    MessageSuggestion(
      style: json['style'] as String,
      text: json['text'] as String,
      expectedImpact: (json['expected_impact'] as num).toInt(),
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$MessageSuggestionToJson(MessageSuggestion instance) =>
    <String, dynamic>{
      'style': instance.style,
      'text': instance.text,
      'expected_impact': instance.expectedImpact,
      'explanation': instance.explanation,
    };

PredictNextResponse _$PredictNextResponseFromJson(Map<String, dynamic> json) =>
    PredictNextResponse(
      sessionId: json['session_id'] as String,
      relationship: json['relationship'] as String,
      relationshipInfo: json['relationship_info'] as String,
      totalMessages: (json['total_messages'] as num).toInt(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => MessageSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PredictNextResponseToJson(
        PredictNextResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'relationship': instance.relationship,
      'relationship_info': instance.relationshipInfo,
      'total_messages': instance.totalMessages,
      'suggestions': instance.suggestions,
    };

StartConversationRequest _$StartConversationRequestFromJson(
        Map<String, dynamic> json) =>
    StartConversationRequest(
      relationship: json['relationship'] as String,
    );

Map<String, dynamic> _$StartConversationRequestToJson(
        StartConversationRequest instance) =>
    <String, dynamic>{
      'relationship': instance.relationship,
    };

StartConversationResponse _$StartConversationResponseFromJson(
        Map<String, dynamic> json) =>
    StartConversationResponse(
      message: json['message'] as String,
      threadId: json['thread_id'] as String,
    );

Map<String, dynamic> _$StartConversationResponseToJson(
        StartConversationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'thread_id': instance.threadId,
    };

ContinueConversationRequest _$ContinueConversationRequestFromJson(
        Map<String, dynamic> json) =>
    ContinueConversationRequest(
      message: json['message'] as String,
      threadId: json['thread_id'] as String,
    );

Map<String, dynamic> _$ContinueConversationRequestToJson(
        ContinueConversationRequest instance) =>
    <String, dynamic>{
      'message': instance.message,
      'thread_id': instance.threadId,
    };

ConversationResponse _$ConversationResponseFromJson(
        Map<String, dynamic> json) =>
    ConversationResponse(
      emotionalTone: json['emotional_tone'] as String,
      appropriatenessRating: (json['appropriateness_rating'] as num).toInt(),
      impactScore: (json['impact_score'] as num).toInt(),
      reviewComment: json['review_comment'] as String,
      suggestedAlternative: json['suggested_alternative'] as String,
    );

Map<String, dynamic> _$ConversationResponseToJson(
        ConversationResponse instance) =>
    <String, dynamic>{
      'emotional_tone': instance.emotionalTone,
      'appropriateness_rating': instance.appropriatenessRating,
      'impact_score': instance.impactScore,
      'review_comment': instance.reviewComment,
      'suggested_alternative': instance.suggestedAlternative,
    };

ContinueConversationResponse _$ContinueConversationResponseFromJson(
        Map<String, dynamic> json) =>
    ContinueConversationResponse(
      message: json['message'] as String,
      response: ConversationResponse.fromJson(
          json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContinueConversationResponseToJson(
        ContinueConversationResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'response': instance.response,
    };
