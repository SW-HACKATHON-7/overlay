// lib/core/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  // 1. Dio 인스턴스 생성
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://3.239.81.172', // 2. 명세서의 Base URL
      connectTimeout: Duration(seconds: 5), // 5초
      receiveTimeout: Duration(seconds: 3), // 3초
    ),
  );

  // 3. (선택) 디버깅을 위한 LogInterceptor 추가
  DioClient() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  // 4. 외부에서 사용할 수 있도록 getter 제공
  Dio get dio => _dio;
}
