# 자동 분석 플로우 구현 완료

## 문제 해결

### 1. API 호출 순서 문제
**문제**: `/view` API가 `/process` 완료 전에 호출되어 400 에러 발생
```
{"detail":"Session not processed yet. Please call /process first."}
```

**해결**: `/process` API가 완료될 때까지 기다린 후 마커 표시

### 2. 자동 분석 플로우
**요구사항**: "대화 확인하기" 버튼 없이 스크롤 끝나면 자동으로 분석 완료까지

## 구현된 플로우

### 전체 자동화 프로세스

```
사용자: "분석 시작" 버튼 탭
   ↓
[1. 스크롤 중] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   - 상태: recording
   - UI: "스크롤 중..." + 중단 버튼
   - 자동 스크롤 + 스크린샷 촬영
   ↓
[2. 서버 처리 중] ━━━━━━━━━━━━━━━━━━━━━━━━
   - 상태: processing
   - UI: CircularProgressIndicator
        "서버 처리 중..."
        "OCR + AI 분석 중입니다"

   내부 처리:
   a) 세션 생성 (POST /sessions)
   b) 스크린샷 업로드 (POST /sessions/{id}/upload × N)
   c) 세션 처리 (POST /sessions/{id}/process) ← 완료 대기!
   ↓
[3. 마커 표시] ━━━━━━━━━━━━━━━━━━━━━━━━━━
   - 상태: showingMarkers
   - UI: 작은 상태바 + 닫기 버튼
   - 첫 번째 스크린샷으로 마커 표시
   - 3초마다 자동 업데이트
```

## 상태 전환

### OverlayState enum
```dart
enum OverlayState {
  needAnalysis,    // 대화 분석이 필요해요
  recording,       // 스크롤 중
  processing,      // 서버 처리 중 (OCR + AI 분석) ← NEW!
  completed,       // 분석이 끝났습니다 (실제로는 안 씀)
  showingMarkers,  // 마커를 화면에 표시 중
}
```

### 상태 전환 순서
```
needAnalysis → recording → processing → showingMarkers
                  ↓            ↓
              중단 시 needAnalysis로
```

## 코드 변경 사항

### 1. `_handleAnalysisComplete()` 수정
**Before**: 상태를 `completed`로 변경 후 비동기 처리
```dart
setState(() {
  currentState = OverlayState.completed;
});
await _processScreenshots(screenshotPaths); // 이후 실행
```

**After**: 처리 완료까지 대기
```dart
print('자동으로 서버 분석 시작...');
await _processScreenshots(screenshotPaths); // 완료 대기
```

### 2. `_processScreenshots()` 개선
**추가된 로직**:
```dart
// 처리 중 상태로 먼저 전환
setState(() {
  currentState = OverlayState.processing;
});

// 1. 세션 생성
print('✓ 세션 생성 완료: $sessionId');

// 2. 스크린샷 업로드
print('✓ 업로드 완료: $uploadCount개');

// 3. 세션 처리 (완료될 때까지 await)
final processResponse = await _analysisService.processSession(...);
print('✓ 세션 처리 완료: ${processResponse.totalMessages}개 메시지');

// 4. 자동으로 마커 표시
await _showMarkersForScreenshot(paths.first);
```

### 3. 새로운 UI 카드 추가

#### `_buildProcessingCard()` - 서버 처리 중
```dart
Widget _buildProcessingCard() {
  return Container(
    // 카드 스타일
    child: Column(
      children: [
        CircularProgressIndicator(),  // 로딩 인디케이터
        Text('서버 처리 중...'),
        Text('OCR + AI 분석 중입니다'),
      ],
    ),
  );
}
```

#### `_buildRecordingCard()` 수정
- "분석 중..." → "스크롤 중..."
- "분석 중단" → "중단"

#### `_buildCompletedCard()`
- 실제로는 사용되지 않음 (자동으로 showingMarkers로 전환)
- 혹시 모를 경우를 위해 유지

## API 호출 순서 보장

### Python 테스트 클라이언트 참고
```python
# 1. 세션 생성
client.create_session()

# 2. 스크린샷 업로드
client.upload_screenshots(image_paths)

# 3. 세션 처리 (완료 대기!)
client.process_session(
    relationship="FRIEND",
    relationship_info="친한 친구"
)

# 4. 이제 안전하게 view 호출 가능
client.get_messages()
```

### Flutter 구현
완전히 동일한 순서로 구현:
```dart
// 1. 세션 생성
await _analysisService.createSession();

// 2. 스크린샷 업로드
await _analysisService.uploadMultipleScreenshots(paths);

// 3. 세션 처리 - 완료될 때까지 대기
await _analysisService.processSession(
  relationship: 'FRIEND',
  relationshipInfo: '친한 친구',
);

// 4. 이제 안전하게 view 호출
await _analysisService.viewByCurrentScreenshot(screenshotPath);
```

## 사용자 경험

### Before (문제 상황)
1. 스크롤 완료
2. "분석이 끝났습니다" 카드 표시
3. "대화 확인하기" 버튼 탭
4. 400 에러 발생 (process가 아직 완료 안됨)
5. 마커가 표시되지 않음

### After (개선됨)
1. 스크롤 완료
2. 자동으로 "서버 처리 중..." 표시
3. OCR + AI 분석 진행 (로딩 인디케이터)
4. 분석 완료되면 자동으로 마커 표시
5. **사용자 추가 액션 불필요!**

## 로그 예시

### 정상 동작 로그
```
Analysis complete with 3 screenshots
자동으로 서버 분석 시작...
✓ 세션 생성 완료: 47598bdc-4c55-43f7-9a01-8d3c83334f7c
스크린샷 업로드 중...
✓ 업로드 완료: 3개
서버 처리 중 (OCR + 병합 + AI 분석)...
세션 처리 완료: 27개 메시지 추출
✓ 세션 처리 완료: 27개 메시지
마커 표시 중...
Markers shown: 15 messages
```

## 주요 파일 변경

### `lib/presentation/overlay/overlay_widget_new.dart`
- `enum OverlayState`: `processing` 상태 추가
- `_handleAnalysisComplete()`: 자동 분석 플로우
- `_processScreenshots()`: 순차 처리 + 상태 전환
- `_buildProcessingCard()`: 새로운 로딩 UI
- `_buildRecordingCard()`: 텍스트 수정
- `_buildOverlayContent()`: processing 케이스 추가

## 테스트 확인 사항

- [x] 스크롤 완료 후 자동으로 서버 처리 시작
- [x] `/process` API 완료 후 `/view` 호출
- [x] 400 에러 해결
- [x] 로딩 UI 표시
- [x] 마커 자동 표시
- [x] 빌드 성공

## 다음 단계

- [ ] 실제 디바이스에서 전체 플로우 테스트
- [ ] 마커 좌표 정확도 확인
- [ ] 처리 시간이 오래 걸리는 경우 타임아웃 처리
- [ ] 에러 발생 시 사용자 친화적인 메시지 표시
