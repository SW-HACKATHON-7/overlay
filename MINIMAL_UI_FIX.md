# 마커 표시 중 UI 최소화

## 문제

### 1. 스크린샷 실패
```
E/Screenshot: acquireLatestImage returned null
Error taking screenshot: PlatformException(CAPTURE_FAILED, Failed to capture screen, null, null)
```

**원인**: 오버레이의 카드가 화면을 가려서 스크린샷 촬영 실패

### 2. UI가 마커를 가림
- "분석 중 N개 메시지" 카드가 상단에 표시됨
- 카드가 마커를 가림
- 사용자가 메시지를 볼 수 없음

## 해결 방법

### Before: 큰 카드 표시
```dart
Widget _buildShowingMarkersCard() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16),
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        Text('분석 중'),
        Text('N개 메시지'),
        IconButton(icon: Icons.close),
      ],
    ),
  );
}
```

**문제**:
- 카드가 화면 상단을 차지
- 스크린샷 촬영 방해
- 마커가 카드에 가려짐

### After: X 버튼만 표시 (오른쪽 상단)
```dart
Widget _buildShowingMarkersCard() {
  return Positioned(
    top: 16,
    right: 16,  // 오른쪽 상단
    child: GestureDetector(
      onTap: _closeOverlay,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: 24),
      ),
    ),
  );
}
```

**개선점**:
- 최소한의 공간만 차지
- 화면을 거의 가리지 않음
- 스크린샷 촬영 가능
- 마커가 잘 보임

## 렌더링 구조 변경

### Before: 모든 상태에서 동일한 구조
```dart
Stack(
  children: [
    if (showingMarkers) ..._buildMarkers(),
    Positioned(child: _buildOverlayContent()),  // 항상 표시
  ]
)
```

### After: 상태별로 다른 구조
```dart
Stack(
  children: [
    if (showingMarkers) ...[
      // 마커 표시 중
      ..._buildMarkers(),
      _buildShowingMarkersCard(),  // X 버튼만
    ] else ...[
      // 다른 상태
      Positioned(child: _buildOverlayContent()),  // 일반 카드
    ],
  ]
)
```

**장점**:
- showingMarkers 상태에서 UI 최소화
- 다른 상태는 기존 UI 유지
- 조건부 렌더링으로 명확한 구분

## UI 흐름

### 1. needAnalysis (분석 필요)
```
┌──────────────────────────────┐
│ 대화 분석이 필요해요          │
│ [분석 시작 버튼]             │
└──────────────────────────────┘
```

### 2. recording (스크롤 중)
```
┌──────────────────────────────┐
│ 스크롤 중...                 │
│ [중단 버튼]                  │
└──────────────────────────────┘
```

### 3. processing (서버 처리)
```
┌──────────────────────────────┐
│    🔄                        │
│ 서버 처리 중...              │
│ OCR + AI 분석 중입니다       │
└──────────────────────────────┘
```

### 4. showingMarkers (마커 표시) ✨ NEW
```
                        ┌───┐
                        │ X │  ← 오른쪽 상단에만!
                        └───┘

🔴 8  (400, 840)
🔴 7  (450, 1200)
🔴 9  (380, 1500)
...
```

## 스크린샷 실패 해결

### 원인
- 오버레이 카드가 화면을 가림
- MediaProjection이 오버레이를 포함해서 캡처
- 오버레이 때문에 원본 화면 캡처 실패

### 해결
1. **UI 최소화**: 작은 X 버튼만 표시
2. **투명 배경**: Scaffold backgroundColor = transparent
3. **위치 조정**: 오른쪽 상단 구석에만 배치

### 예상 결과
```
Before:
ERROR: acquireLatestImage returned null (카드가 화면 가림)

After:
SUCCESS: Screenshot captured (X 버튼만 있어서 방해 안 됨)
```

## 빌드 완료

```bash
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## 변경 사항 요약

### 파일: `overlay_widget_new.dart`

#### 1. `build()` 메서드
- showingMarkers 상태일 때 다른 렌더링
- X 버튼만 표시

#### 2. `_buildShowingMarkersCard()`
- Container → Positioned로 변경
- 큰 카드 → 작은 원형 버튼
- 왼쪽 정렬 → 오른쪽 상단 배치
- 텍스트 제거, 아이콘만 유지

#### 3. `_buildOverlayContent()`
- showingMarkers 케이스에서 `SizedBox.shrink()` 반환
- 불필요한 렌더링 방지

## 테스트 확인 사항

- [x] X 버튼이 오른쪽 상단에 표시됨
- [x] 마커가 화면 전체에 표시 가능
- [ ] 스크린샷 촬영 성공 (에러 없음)
- [ ] 마커가 빨간색 원으로 보임
- [ ] X 버튼 터치 시 오버레이 종료

## 추가 개선 사항

### X 버튼 스타일링
현재는 흰색 원에 검은색 X입니다. 필요하면:

```dart
// 반투명 배경
color: Colors.black.withOpacity(0.5),

// 흰색 X
child: Icon(Icons.close, color: Colors.white),
```

### 마커 터치 영역
마커를 터치하면 상세 정보 표시:

```dart
GestureDetector(
  onTap: () => _showMessageDetail(msg),
  child: // 마커
)
```

현재는 print만 하지만, 나중에 모달로 변경 가능
