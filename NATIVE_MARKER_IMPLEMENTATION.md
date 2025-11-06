# Android 네이티브 마커 구현

Flutter 오버레이에서 마커가 계속 안 보이는 문제로 인해 **Android 네이티브 코드로 직접 마커를 그리도록 재구현**했습니다.

## 구현 구조

```
Flutter (데이터 수신)
    ↓ MethodChannel
Android Native (마커 표시)
    ↓ WindowManager
화면에 마커 오버레이 표시
```

## 새로 추가된 파일

### 1. `MarkerOverlayService.kt`
**위치**: `android/app/src/main/kotlin/com/example/overlay/MarkerOverlayService.kt`

**역할**: WindowManager를 사용해서 화면에 마커를 직접 표시

**주요 기능**:
- `showMarkers(markersJson: String)`: JSON 데이터를 받아서 마커 표시
- `clearMarkers()`: 모든 마커 제거
- `createMarkerView(score: Int)`: 마커 View 생성

**구현 방식**:
```kotlin
// 마커 View 생성
val markerView = TextView(this).apply {
    text = score.toString()  // 점수 표시
    setBackgroundColor(Color.RED)  // 빨간색 배경
    layoutParams = LayoutParams(100, 100)  // 100px 원
}

// WindowManager에 추가
val params = WindowManager.LayoutParams(
    WRAP_CONTENT, WRAP_CONTENT,
    TYPE_APPLICATION_OVERLAY,  // 오버레이 타입
    FLAG_NOT_FOCUSABLE,  // 포커스 안 받음
    TRANSLUCENT
).apply {
    x = marker.x  // 절대 좌표
    y = marker.y
}

windowManager.addView(markerView, params)
```

## 데이터 플로우

### 1. Flutter → Native (좌표 전달)
```dart
// Flutter
final markersData = [
  {'x': 358.0, 'y': 1111.0, 'score': 8},
  {'x': 319.0, 'y': 1649.0, 'score': 6},
];
final json = jsonEncode(markersData);
await ScreenshotService.showMarkers(json);
```

### 2. MethodChannel 통신
```kotlin
// MainActivity.kt
MethodChannel.setMethodCallHandler { call, result ->
    when (call.method) {
        "showMarkers" -> {
            val markersJson = call.argument<String>("markers")
            showMarkers(markersJson)  // Service 시작
            result.success(true)
        }
        "clearMarkers" -> {
            clearMarkers()  // Service에 제거 명령
            result.success(null)
        }
    }
}
```

### 3. Service에서 마커 표시
```kotlin
// MarkerOverlayService.kt
private fun showMarkers(markersJson: String) {
    val markersArray = JSONArray(markersJson)

    for (i in 0 until markersArray.length()) {
        val marker = markersArray.getJSONObject(i)
        val x = marker.getDouble("x").toFloat()
        val y = marker.getDouble("y").toFloat()
        val score = marker.getInt("score")

        // 마커 View 생성 및 표시
        val markerView = createMarkerView(score)
        windowManager.addView(markerView, params)
        markerViews.add(markerView)
    }
}
```

## 수정된 파일

### 1. `MainActivity.kt`
**추가된 메서드**:
- `showMarkers(markersJson: String)`: MarkerOverlayService 시작
- `clearMarkers()`: 마커 제거 명령

### 2. `ScreenshotService.dart`
**추가된 메서드**:
```dart
static Future<bool> showMarkers(String markersJson)
static Future<void> clearMarkers()
```

### 3. `overlay_widget_new.dart`
**추가된 메서드**:
```dart
Future<void> _showNativeMarkers(List<MessageDetail> messages) {
    // 1. user 메시지 필터링
    // 2. JSON 변환
    // 3. 네이티브 호출
}
```

**수정된 메서드**:
- `_showMarkersForScreenshot()`: 네이티브 마커 호출 추가
- `_updateMarkersWithScreenshot()`: 마커 업데이트 시 네이티브 호출
- `_closeOverlay()`: 종료 시 마커 제거

### 4. `AndroidManifest.xml`
```xml
<service
    android:name=".MarkerOverlayService"
    android:exported="false" />
```

## JSON 데이터 형식

### Flutter → Native 전달 형식
```json
[
  {
    "x": 358.0,
    "y": 1111.0,
    "score": 8,
    "text": "이제 r어요. 다음엔 이런 거 30분 전에 쥐요"
  },
  {
    "x": 319.0,
    "y": 1649.0,
    "score": 6,
    "text": "그래도 8시 반 '전에' 젊으면 중계"
  }
]
```

## 마커 표시 타이밍

### 1. 최초 표시
```
분석 완료 → 첫 스크린샷으로 /view 호출
    ↓
API 응답 (좌표 데이터)
    ↓
_showNativeMarkers() 호출
    ↓
네이티브 마커 표시
```

### 2. 주기적 업데이트 (3초마다)
```
새 스크린샷 촬영 → /view 호출
    ↓
새 좌표 데이터
    ↓
_updateMarkersWithScreenshot()
    ↓
clearMarkers() + showMarkers()
    ↓
마커 위치 업데이트
```

### 3. 종료 시
```
X 버튼 탭 → _closeOverlay()
    ↓
clearMarkers()
    ↓
모든 마커 제거
```

## 좌표 시스템

### Flutter에서 전달하는 좌표
- API에서 받은 **원본 좌표** 그대로 전달
- 예: `x: 358.0, y: 1111.0` (픽셀 단위)

### Android에서 처리
- WindowManager.LayoutParams의 `x`, `y`에 직접 설정
- **절대 좌표**로 동작 (화면 전체 기준)
- devicePixelRatio 변환 불필요

## 로그 확인 포인트

### Flutter 로그
```
Showing 4 native markers
Markers JSON: [{"x":358.0,"y":1111.0,"score":8,"text":"..."}]
✓ Native markers displayed successfully
```

### Android 로그
```
D/MarkerOverlayService: Showing 4 markers
D/MarkerOverlayService: Creating marker at (358.0, 1111.0) with score 8
D/MarkerOverlayService: Marker added at (358.0, 1111.0)
D/MarkerOverlayService: Total markers displayed: 4
```

## 장점

### Flutter 오버레이 대비
1. **절대 좌표 사용**: 좌표 변환 불필요
2. **네이티브 렌더링**: 성능 우수
3. **독립적인 레이어**: Flutter UI와 충돌 없음
4. **디버깅 용이**: Android 로그로 직접 확인

## 빌드 완료

```bash
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## 테스트 확인 사항

### APK 설치 후
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### 로그 확인
```bash
# Flutter 로그
adb logcat | grep "flutter"

# Native 로그
adb logcat | grep "MarkerOverlay"
```

### 화면 확인
1. 분석 시작 → 스크롤 → 처리 완료
2. **빨간색 원**이 화면에 보이는지
3. 원 안에 **점수 숫자**가 표시되는지
4. 스크롤 시 마커 위치가 **업데이트**되는지
5. X 버튼 탭 시 마커가 **사라지는지**

## 다음 단계 개선

### 1. 마커 디자인 개선
현재는 간단한 TextView입니다. 더 예쁘게:
```kotlin
// 커스텀 Drawable 사용
val drawable = GradientDrawable().apply {
    shape = GradientDrawable.OVAL
    setColor(Color.RED)
}
markerView.background = drawable
```

### 2. 점수별 색상 차별화
```kotlin
val color = when {
    score >= 8 -> Color.GREEN
    score >= 6 -> Color.YELLOW
    else -> Color.RED
}
```

### 3. 터치 이벤트
```kotlin
markerView.setOnClickListener {
    // 상세 정보 표시
    showDetailDialog(marker)
}
```

### 4. 애니메이션
```kotlin
markerView.apply {
    scaleX = 0f
    scaleY = 0f
    animate()
        .scaleX(1f)
        .scaleY(1f)
        .setDuration(300)
        .start()
}
```

## 트러블슈팅

### 마커가 안 보이는 경우
1. **권한 확인**: SYSTEM_ALERT_WINDOW 권한 허용됐는지
2. **로그 확인**: MarkerOverlayService 로그 출력되는지
3. **좌표 확인**: x, y 값이 화면 범위 내인지
4. **Service 상태**: Service가 실행 중인지

### 마커가 잘못된 위치에 표시
1. **좌표 스케일링**: 혹시 필요하면 나누기 적용
2. **Gravity 설정**: TOP | START로 되어있는지
3. **WindowManager 타입**: TYPE_APPLICATION_OVERLAY 사용하는지
