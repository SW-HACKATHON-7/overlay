import 'package:hackerton/data/dto/main_api_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'dart:io'; // File

part 'api_service.g.dart'; // 코드 생성기가 만들 파일

@RestApi(baseUrl: "http://3.239.81.172/")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // 1. 세션 생성
  @POST("/sessions")
  Future<SessionResponse> createSession();

  // 2. 스크린샷 업로드
  // cURL의 -F "file=@..."는 @MultiPart와 @Part로 변환됩니다.
  @POST("/sessions/{session_id}/upload")
  @MultiPart()
  Future<UploadResponse> uploadScreenshot(
    @Path("session_id") String sessionId,
    @Part(name: "file") File file, // dart:io의 File 객체
  );

  // 3. 세션 처리
  // 쿼리 파라미터는 @Query로 추가합니다.
  @POST("/sessions/{session_id}/process")
  Future<ProcessResponse> processSession(
    @Path("session_id") String sessionId,
    @Query("relationship") String relationship,
    @Query("relationship_info") String relationshipInfo,
  );

  // 4. 메시지 조회
  @GET("/sessions/{session_id}/messages")
  Future<MessagesResponse> getMessages(@Path("session_id") String sessionId);

  // 5. 스크린샷으로 검색
  @POST("/sessions/{session_id}/search")
  @MultiPart()
  Future<SearchResponse> searchByScreenshot(
    @Path("session_id") String sessionId,
    @Part(name: "file") File file,
  );
}
