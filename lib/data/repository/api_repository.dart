import 'dart:io';

import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:hackerton/data/service/api_service.dart';

abstract class ApiRepository {
  Future<SessionResponse> createSession();
  Future<UploadResponse> uploadScreenshot({required String sessionId, required File file});
  Future<ProcessResponse> processSession({
    required String sessionId,
    required String relationship,
    required String relationshipInfo,
  });
  Future<MessagesResponse> getMessages({required String sessionId});
  Future<SearchResponse> searchByScreenshot({required String sessionId, required File file});
  Future<ViewResponse> viewByScreenshots({required String sessionId, required List<File> files});
  Future<PredictNextResponse> predictNextMessage({required String sessionId});
  Future<StartConversationResponse> startConversation({required String relationship});
  Future<ContinueConversationResponse> continueConversation({
    required String message,
    required String threadId,
  });
}

class ApiRepositoryImpl implements ApiRepository {
  final ApiService apiService;

  ApiRepositoryImpl({required this.apiService});

  @override
  Future<SessionResponse> createSession() {
    return apiService.createSession();
  }

  @override
  Future<UploadResponse> uploadScreenshot({required String sessionId, required File file}) {
    return apiService.uploadScreenshot(sessionId, file);
  }

  @override
  Future<ProcessResponse> processSession({
    required String sessionId,
    required String relationship,
    required String relationshipInfo,
  }) {
    return apiService.processSession(sessionId, relationship, relationshipInfo);
  }

  @override
  Future<MessagesResponse> getMessages({required String sessionId}) {
    return apiService.getMessages(sessionId);
  }

  @override
  Future<SearchResponse> searchByScreenshot({required String sessionId, required File file}) {
    return apiService.searchByScreenshot(sessionId, file);
  }

  @override
  Future<ViewResponse> viewByScreenshots({required String sessionId, required List<File> files}) {
    return apiService.viewByScreenshots(sessionId, files);
  }

  @override
  Future<PredictNextResponse> predictNextMessage({required String sessionId}) {
    return apiService.predictNextMessage(sessionId);
  }

  @override
  Future<StartConversationResponse> startConversation({required String relationship}) {
    return apiService.startConversation(StartConversationRequest(relationship: relationship));
  }

  @override
  Future<ContinueConversationResponse> continueConversation({
    required String message,
    required String threadId,
  }) {
    return apiService.continueConversation(
      ContinueConversationRequest(message: message, threadId: threadId),
    );
  }
}


