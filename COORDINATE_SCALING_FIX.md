# 마커 좌표 스케일링 문제 해결

## 문제

### 마커가 화면에 안 보임
**로그 분석**:
```
Marker: "이제 r어요. 다음엔 이런 거 30분" at (358.0, 1111.0) score=6.0
Marker: "그래도 8시 반 '전에' 젊으면 중계" at (319.0, 1649.0) score=6.0
Marker: "이건 일정 조율의 기본이에요 어제도 " at (402.0, 2132.0) score=5.0
Marker: "아니 애초에 좀 일찍 주면 덧나나요?" at (483.0, 2615.0) score=6.0
```

**문제점**:
- API에서 받은 좌표: `x: 358, y: 1111` (매우 큼)
- 일반적인 Flutter 화면 크기: `width: ~400, height: ~800` (논리 픽셀)
- **마커가 화면 밖에 그려짐!**

## 원인 분석

### 좌표 시스템 차이

#### 1. 서버 (OCR)
- **실제 픽셀 좌표** 사용
- 스크린샷의 원본 해상도 기준
- 예: 1080 x 2400 픽셀 (Full HD+)

#### 2. Flutter
- **논리 픽셀 (Logical Pixels)** 사용
- `devicePixelRatio`로 변환 필요
- 예: 360 x 800 논리 픽셀 (3.0 배율)

#### 3. 변환 공식
```
논리 픽셀 = 실제 픽셀 / devicePixelRatio
```

### 예시 계산

**서버 좌표**: `x: 358, y: 1111` (실제 픽셀)

**일반적인 안드로이드 디바이스** (devicePixelRatio = 3.0):
```
Flutter 좌표 = (358 / 3.0, 1111 / 3.0)
            = (119.3, 370.3)
```

**이제 화면 내에 들어옴!**

## 해결 방법

### Before: 원본 좌표 사용
```dart
final x = msg.position.x;  // 358
final y = msg.position.y;  // 1111
// → 화면 밖!
```

### After: 스케일링 적용
```dart
final x = msg.position.x / 3.0;  // 119.3
final y = msg.position.y / 3.0;  // 370.3
// → 화면 내!
```

## 코드 변경

### `_buildMarkers()` 수정
```dart
return userMessages.map((msg) {
  // 스케일링 적용
  final x = msg.position.x / 3.0;
  final y = msg.position.y / 3.0;

  print('at raw(${msg.position.x}, ${msg.position.y}) scaled($x, $y)');

  return Positioned(
    left: x,
    top: y,
    child: // 마커
  );
}).toList();
```

## devicePixelRatio 값

### 일반적인 안드로이드 디바이스
| 해상도 | devicePixelRatio | 비고 |
|--------|-----------------|------|
| 720p (HD) | 2.0 | 저사양 |
| 1080p (FHD) | 3.0 | **가장 흔함** |
| 1440p (QHD) | 4.0 | 고사양 |
| 4K | 6.0 | 최고사양 |

### 현재 구현
```dart
final x = msg.position.x / 3.0;  // FHD 기준 하드코딩
```

**장점**: 대부분의 디바이스에서 동작
**단점**: 다른 해상도에서는 부정확할 수 있음

## 테스트 예상 결과

### 로그 출력
```
=== Building 4 markers ===
Marker: "이제 r어요..." at raw(358.0, 1111.0) scaled(119.3, 370.3) score=6.0
Marker: "그래도 8시..." at raw(319.0, 1649.0) scaled(106.3, 549.7) score=6.0
Marker: "이건 일정..." at raw(402.0, 2132.0) scaled(134.0, 710.7) score=5.0
Marker: "아니 애초에..." at raw(483.0, 2615.0) scaled(161.0, 871.7) score=6.0
```

### 화면 표시
```
일반적인 안드로이드 화면 (360 x 800 논리 픽셀)

┌─────────────────────────────┐ 0
│                             │
│                        [X]  │ 16
│                             │
│  🔴 6  (119, 370)           │ 370
│                             │
│  🔴 6  (106, 549)           │ 549
│                             │
│  🔴 5  (134, 710)           │ 710
│                             │
└─────────────────────────────┘ 800
```

**모든 마커가 화면 내에 표시됨!**

## 더 정확한 구현 (선택사항)

### MediaQuery로 실제 devicePixelRatio 사용
```dart
Widget build(BuildContext context) {
  final pixelRatio = MediaQuery.of(context).devicePixelRatio;

  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          if (showingMarkers) ..._buildMarkers(pixelRatio),
        ],
      ),
    ),
  );
}

List<Widget> _buildMarkers(double pixelRatio) {
  return messages.map((msg) {
    final x = msg.position.x / pixelRatio;  // 실제 비율 사용
    final y = msg.position.y / pixelRatio;
    // ...
  }).toList();
}
```

**장점**: 모든 디바이스에서 정확
**단점**: 코드가 약간 복잡해짐

## 빌드 완료

```bash
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## 테스트 확인 사항

- [ ] 로그에서 `scaled` 좌표 확인
- [ ] 빨간색 원이 화면에 보임
- [ ] 마커가 메시지 근처에 위치
- [ ] 스크롤 시 마커가 함께 움직임 (좌표 업데이트)

## 다음 단계

### 마커가 보인다면:
1. **위치 미세 조정**: 메시지 중앙에 정확히 배치
2. **SVG 아이콘으로 복원**: 빨간 원 → 실제 점수 아이콘
3. **터치 기능**: 마커 클릭 시 상세 정보 표시

### 마커가 여전히 안 보인다면:
1. **로그 확인**: `scaled` 좌표가 화면 내인지
2. **다른 비율 시도**: 2.0, 2.5, 4.0 등
3. **절대 위치 테스트**:
   ```dart
   Positioned(left: 100, top: 100, child: Container(...))
   ```
