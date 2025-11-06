import 'dart:io';

import 'package:dio/dio.dart';
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
}


