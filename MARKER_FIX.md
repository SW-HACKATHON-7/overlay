# 마커 표시 문제 해결

## 문제
```
Error taking screenshot: MissingPluginException(No implementation found for method takeScreenshot on channel com.example.overlay/screenshot)
```

오버레이 위젯이 별도의 isolate에서 실행되기 때문에 MethodChannel을 직접 호출할 수 없었습니다.

## 해결 방법

### 1. 첫 마커 표시: 업로드한 스크린샷 재사용
분석 완료 후 첫 마커를 표시할 때, 이미 업로드한 스크린샷 중 첫 번째 파일을 사용합니다.

**Before:**
```dart
// 오버레이에서 직접 스크린샷 촬영 시도 (실패)
final screenshotPath = await ScreenshotService.takeScreenshot();
```

**After:**
```dart
// 업로드한 첫 번째 스크린샷 사용
if (paths.isNotEmpty) {
  await _showMarkersForScreenshot(paths.first);
}
```

### 2. 화면 변경 감지: 메인 앱에 스크린샷 요청
주기적인 마커 업데이트를 위해 메인 앱과 오버레이 간 통신 프로토콜을 확장했습니다.

#### 오버레이 → 메인 앱 (요청)
```dart
// 3초마다 메인 앱에 스크린샷 촬영 요청
Timer.periodic(const Duration(seconds: 3), (timer) async {
  homePort?.send('COMMAND:TAKE_SCREENSHOT');
});
```

#### 메인 앱 (처리)
```dart
if (message == 'COMMAND:TAKE_SCREENSHOT') {
  // 단일 스크린샷 촬영
  final screenshotPath = await ScreenshotService.takeScreenshot();

  // 스크린샷 경로를 오버레이로 전송
  overlayPort?.send('SCREENSHOT:$screenshotPath');
}
```

#### 오버레이 (응답 처리)
```dart
if (message.startsWith('SCREENSHOT:')) {
  final path = message.replaceFirst('SCREENSHOT:', '');
  if (currentState == OverlayState.showingMarkers) {
    _updateMarkersWithScreenshot(path);
  }
}
```

### 3. 마커 업데이트 로직
```dart
Future<void> _updateMarkersWithScreenshot(String screenshotPath) async {
  // 이전 스크린샷과 같으면 무시
  if (screenshotPath == _lastScreenshotPath) return;

  _lastScreenshotPath = screenshotPath;

  // 새로운 화면의 메시지 조회
  final viewResponse = await _analysisService.viewByCurrentScreenshot(screenshotPath);

  if (viewResponse != null && viewResponse.messages.isNotEmpty) {
    setState(() {
      _currentMessages = viewResponse.messages;
    });
  }
}
```

## 통신 프로토콜 확장

### 오버레이 → 메인 앱
| 명령 | 설명 |
|------|------|
| `COMMAND:START_AUTO_SCROLL` | 자동 스크롤 시작 요청 |
| `COMMAND:STOP_AUTO_SCROLL` | 자동 스크롤 중지 요청 |
| `COMMAND:TAKE_SCREENSHOT` | **[NEW]** 단일 스크린샷 촬영 요청 |

### 메인 앱 → 오버레이
| 응답 | 설명 |
|------|------|
| `SUCCESS:{paths}` | 자동 스크롤 완료 (스크린샷 경로들) |
| `ERROR:{message}` | 에러 발생 |
| `STOPPED` | 스크롤 중지됨 |
| `SCREENSHOT:{path}` | **[NEW]** 스크린샷 촬영 완료 (경로 전달) |

## 동작 플로우

### 초기 마커 표시
```
1. 자동 스크롤 완료 → 스크린샷 경로들 수신
   ↓
2. 스크린샷 업로드 → 서버 처리 (OCR + 분석)
   ↓
3. 업로드한 첫 번째 스크린샷으로 마커 표시
   ↓
4. POST /sessions/{id}/view → 좌표 수신 → 마커 표시
```

### 주기적 마커 업데이트
```
3초마다:
  오버레이 → 메인 앱: "COMMAND:TAKE_SCREENSHOT"
     ↓
  메인 앱: 스크린샷 촬영
     ↓
  메인 앱 → 오버레이: "SCREENSHOT:{path}"
     ↓
  오버레이: POST /sessions/{id}/view
     ↓
  마커 위치 업데이트
```

## 주요 수정 파일

### `lib/presentation/overlay/overlay_widget_new.dart`
- `_processScreenshots()`: 업로드한 첫 스크린샷으로 마커 표시
- `_showMarkersForScreenshot()`: 특정 스크린샷으로 마커 표시
- `_startScreenChangeDetection()`: 3초마다 메인 앱에 스크린샷 요청
- `_requestScreenshotUpdate()`: 메인 앱에 스크린샷 요청 전송
- `_updateMarkersWithScreenshot()`: 받은 스크린샷으로 마커 업데이트
- 메시지 수신 로직: `SCREENSHOT:` 처리 추가

### `lib/main.dart`
- `COMMAND:TAKE_SCREENSHOT` 처리 추가
- 단일 스크린샷 촬영 후 `SCREENSHOT:{path}` 응답 전송

## 장점

1. **Isolate 제약 우회**: 오버레이가 직접 MethodChannel 호출하지 않음
2. **효율적**: 이미 촬영한 스크린샷 재사용
3. **실시간 업데이트**: 3초마다 자동으로 마커 위치 업데이트
4. **확장 가능**: 통신 프로토콜이 명확해서 추가 기능 구현 용이

## 테스트 확인 사항

- [x] 분석 완료 후 마커 표시
- [x] 스크린샷 촬영 에러 해결
- [x] 메인 앱 ↔ 오버레이 통신 정상 작동
- [x] 빌드 성공

## 다음 단계

- [ ] 실제 디바이스에서 마커 표시 테스트
- [ ] 좌표 정확도 확인 (DPI/해상도 보정 필요 여부)
- [ ] 마커 터치 시 상세 정보 모달 구현
- [ ] 성능 최적화 (필요시 업데이트 주기 조정)
