# 마커 디버깅 개선

## 문제 분석

### 1. 스크린샷 1개만 전송? ✅ 정상 동작
**로그 분석**:
```
D/Screenshot: Saved to: screenshot_1762431589673.png
D/Screenshot: Saved to: screenshot_1762431594007.png
File size comparison: 368752 vs 368379 (diff: 0.10%)
Similar file sizes - likely same screen
Similar to previous screen detected. Reached end. Stopping.
Auto scroll completed. Total screenshots: 1
```

**결론**:
- 스크린샷 2개 촬영됨
- 중복 감지 로직이 파일 크기 비교 (0.10% 차이)
- 비슷한 화면으로 판단해서 1개만 전송
- **이것은 정상 동작** (중복 방지 기능)

### 2. 마커가 안 보임 ❌ 문제
**API 응답**:
```json
{
  "message_id": "70c066fe...",
  "text": "내일 회의 전에 결과 정리해서 공유해 주세요",
  "speaker": "user",
  "score": 8.0,
  "position": {
    "x": 400.0,
    "y": 840.0,
    "width": 1022.0,
    "height": 186.0
  }
}
```

**문제**: 좌표 데이터는 정상적으로 수신되었지만 화면에 표시 안됨

## 해결 방안

### 디버깅 기능 추가

#### 1. 마커 생성 로그
```dart
print('=== Building ${userMessages.length} markers ===');
```

#### 2. 각 마커별 좌표 로그
```dart
print('Marker: "${msg.text}" at ($x, $y) score=${msg.score}');
```

#### 3. 시각적 디버깅
**기존**: SVG 아이콘 사용
```dart
SvgPicture.asset(icon, width: 40, height: 40)
```

**수정**: 빨간색 원 + 점수 표시
```dart
Container(
  width: 50,
  height: 50,
  decoration: BoxDecoration(
    color: Colors.red,  // 명확한 빨간색
    shape: BoxShape.circle,
    boxShadow: [...]
  ),
  child: Center(
    child: Text(
      '${msg.score?.toInt()}',  // 점수 표시
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
)
```

### 예상 출력 로그

```
=== Building 9 markers ===
Marker: "내일 회의 전에 결과 정" at (400.0, 840.0) score=8.0
Marker: "그 부분 좀 더 보완해서" at (450.0, 1200.0) score=7.0
...
```

## 마커가 안 보이는 가능성

### 1. 좌표계 문제
- 서버의 좌표: 전체 화면 기준
- 오버레이 위젯: Stack 내부 좌표
- **가능성**: 좌표 변환 필요

### 2. 오버레이 크기 문제
- 오버레이가 전체 화면을 차지하지 않음
- 마커가 오버레이 영역 밖에 그려짐
- **해결**: 오버레이를 전체 화면으로 확장 필요

### 3. Z-index 문제
- 컨트롤 카드가 마커 위에 그려짐
- **현재 구조**:
```dart
Stack(
  children: [
    if (showingMarkers) ..._buildMarkers(),  // 먼저 그림
    Positioned(top: 16, child: _buildCard()), // 나중에 그림 (위에 옴)
  ]
)
```
- **해결**: 순서는 이미 올바름

### 4. 투명도 문제
- Scaffold backgroundColor: Colors.transparent
- 마커가 투명해서 안 보임?
- **해결**: 빨간색으로 명확하게 표시

## 테스트 방법

### 1. 빌드 및 설치
```bash
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### 2. 로그 확인
```bash
adb logcat | grep "flutter"
```

**확인할 로그**:
- `=== Building X markers ===` → 마커 생성 여부
- `Marker: "..." at (x, y)` → 각 마커 좌표
- `Markers shown: X messages` → API 응답 확인

### 3. 화면에서 확인
- 빨간색 원이 보이는지
- 원 안에 점수가 표시되는지
- 터치 시 로그가 출력되는지

## 다음 단계

### 만약 마커가 여전히 안 보인다면:

#### A. 좌표 스케일링 필요
```dart
// 서버 좌표 → 디바이스 좌표 변환
final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
final scaledX = msg.position.x / devicePixelRatio;
final scaledY = msg.position.y / devicePixelRatio;
```

#### B. 오버레이 전체 화면으로 확장
```kotlin
// Android: overlay_widget_new.dart의 메인 앱 부분
FlutterOverlayWindow.showOverlay(
  height: WindowManager.LayoutParams.MATCH_PARENT,
  width: WindowManager.LayoutParams.MATCH_PARENT,
)
```

#### C. 절대 좌표로 테스트
```dart
// 화면 중앙에 테스트 마커
Positioned(
  left: MediaQuery.of(context).size.width / 2,
  top: MediaQuery.of(context).size.height / 2,
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)
```

### 마커가 보인다면:

#### 1. SVG 아이콘으로 복원
```dart
child: SvgPicture.asset(
  getScoreIcon(msg.score),
  width: 40,
  height: 40,
)
```

#### 2. 좌표 보정
```dart
left: msg.position.x - 20,  // 아이콘 중앙 정렬
top: msg.position.y - 20,
```

#### 3. 터치 영역 확대
```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: () => _showMessageDetail(msg),
)
```

## 빌드 완료

```bash
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

### 변경 사항
- 마커를 빨간색 원으로 변경 (디버깅용)
- 각 마커에 점수 표시
- 상세한 로그 추가
- 좌표 보정 제거 (원본 좌표 사용)

### 테스트 확인 사항
- [ ] 로그에서 "=== Building X markers ===" 확인
- [ ] 각 마커의 좌표 확인
- [ ] 화면에 빨간색 원이 보이는지 확인
- [ ] 원의 위치가 메시지 근처인지 확인
- [ ] 터치 시 로그 출력 확인
