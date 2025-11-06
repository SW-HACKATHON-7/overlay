import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackerton/data/repository/api_repository.dart';
import 'package:hackerton/data/service/api_service.dart';
import 'package:hackerton/data/service/dio.dart';

// DioClient Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiService(dioClient.dio);
});

// ApiRepository Provider
final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ApiRepositoryImpl(apiService: apiService);
});
