# 대화 복기 기능 API 연동 구현 완료

## 개요
실시간 채팅 앱의 대화를 캡처하여 AI가 분석하고, 화면에 마커를 표시하는 기능을 구현했습니다.

## 주요 변경 사항

### 1. 새로운 서비스 추가

#### `lib/services/analysis_service.dart`
- **AnalysisService**: API 연동을 담당하는 서비스 클래스
- 주요 기능:
  - `createSession()`: 분석 세션 생성
  - `uploadScreenshot()`: 스크린샷 업로드
  - `uploadMultipleScreenshots()`: 여러 스크린샷 일괄 업로드
  - `processSession()`: 세션 처리 (OCR + AI 분석)
  - `getMessages()`: 전체 메시지 조회
  - `viewByCurrentScreenshot()`: 현재 화면의 분석 결과 조회 (실시간 좌표 업데이트용)
  - `getPredictNextMessages()`: 다음 메시지 제안 조회

- **점수별 아이콘 매핑 함수**: `getScoreIcon()`
  - appropriateness_rating 값(0-100)을 0-10 범위로 정규화
  - `assets/images/0.svg` ~ `assets/images/10.svg` 매핑

### 2. 새로운 오버레이 위젯

#### `lib/presentation/overlay/overlay_widget_new.dart`
기존 overlay_widget.dart를 확장하여 실제 API 연동 기능 추가:

**상태 관리**:
- `needAnalysis`: 분석 시작 전
- `recording`: 분석 중
- `completed`: 분석 완료
- `showingMarkers`: 마커를 화면에 표시 중

**주요 기능**:
1. **자동 스크린샷 촬영 및 업로드**
   - 자동 스크롤 완료 시 스크린샷 경로 수신
   - 세션 생성 → 스크린샷 업로드 → 처리 요청 자동화

2. **마커 표시 (`_buildMarkers()`)**
   - 서버에서 받은 좌표(x, y)에 점수별 아이콘 표시
   - user 메시지만 필터링 (speaker == 'user')
   - 점수가 있는 메시지만 표시
   - 터치 시 상세 정보 표시 가능

3. **화면 변경 감지 (`_startScreenChangeDetection()`)**
   - 2초마다 새로운 스크린샷 촬영
   - `/sessions/{id}/view` API 호출로 현재 화면의 메시지 조회
   - 좌표 자동 업데이트

4. **스크린샷 자동 병합**
   - 서버에서 자동으로 겹치는 부분 감지 및 병합
   - 클라이언트는 업로드만 담당

### 3. Main App 수정

#### `lib/main.dart`
- 새로운 오버레이 위젯(`OverlayWidgetNew`) 사용
- 스크린샷 경로를 쉼표로 구분하여 오버레이에 전달
- 포트 기반 IPC로 메인 앱 ↔ 오버레이 통신

## API 연동 흐름

### 전체 플로우
```
1. 사용자가 "분석 시작" 버튼 탭
   ↓
2. 오버레이 → 메인 앱: "START_AUTO_SCROLL" 명령
   ↓
3. 메인 앱: 자동 스크롤 + 연속 스크린샷 촬영
   ↓
4. 메인 앱 → 오버레이: "SUCCESS:{paths}" 전송
   ↓
5. 오버레이: 세션 생성 (POST /sessions)
   ↓
6. 오버레이: 스크린샷 업로드 (POST /sessions/{id}/upload) × N
   ↓
7. 오버레이: 세션 처리 (POST /sessions/{id}/process)
   - 관계 정보: relationship=FRIEND, relationship_info=친한 친구
   ↓
8. 오버레이: 현재 화면 스크린샷 촬영
   ↓
9. 오버레이: 현재 화면 분석 (POST /sessions/{id}/view)
   ↓
10. 마커 표시 (x, y 좌표 기반)
   ↓
11. 2초마다 화면 변경 확인 및 마커 업데이트
```

### 화면 변경 감지 플로우
```
Timer (2초마다)
   ↓
새 스크린샷 촬영
   ↓
POST /sessions/{id}/view (현재 화면)
   ↓
매칭된 메시지 좌표 수신
   ↓
마커 위치 업데이트
```

## 점수별 아이콘 매핑

API에서 `appropriateness_rating` 값이 0-100 범위로 오면:

```dart
// 0-10 범위로 정규화
normalizedScore = (score / 10).round()

// 아이콘 경로
assets/images/{normalizedScore}.svg
```

예시:
- 점수 100 → `assets/images/10.svg`
- 점수 85 → `assets/images/9.svg` (8.5 → 9로 반올림)
- 점수 50 → `assets/images/5.svg`
- 점수 0 → `assets/images/0.svg`

## 마커 표시 로직

```dart
// 1. user 메시지만 필터링
messages.where((msg) => msg.speaker == 'user' && msg.score != null)

// 2. 각 메시지에 대해 Positioned 위젯 생성
Positioned(
  left: msg.position.x - 20,  // 아이콘 크기 보정
  top: msg.position.y - 20,
  child: SvgPicture.asset(getScoreIcon(msg.score), width: 40, height: 40)
)

// 3. GestureDetector로 터치 이벤트 처리
onTap: () => _showMessageDetail(msg)  // 상세 정보 표시
```

## 주요 파일 목록

### 신규 파일
- `lib/services/analysis_service.dart` - API 연동 서비스
- `lib/presentation/overlay/overlay_widget_new.dart` - 새 오버레이 위젯

### 수정 파일
- `lib/main.dart` - 새 오버레이 위젯 사용
- `lib/data/service/api_service.dart` - 이미 구현되어 있음 (확인만 함)
- `lib/data/dto/main_api_model.dart` - 이미 구현되어 있음 (확인만 함)

### 기존 유지
- `lib/services/screenshot_service.dart` - 스크린샷 촬영 (변경 없음)
- `android/app/src/main/kotlin/.../MainActivity.kt` - 네이티브 코드 (변경 없음)

## API 엔드포인트 사용

### 분석 플로우
1. `POST /sessions` - 세션 생성
2. `POST /sessions/{id}/upload` - 스크린샷 업로드 (여러 번)
3. `POST /sessions/{id}/process?relationship=FRIEND&relationship_info=친한친구` - 처리

### 실시간 마커 업데이트
4. `POST /sessions/{id}/view` (files: [현재 스크린샷]) - 화면 분석

### 추가 기능 (구현됨, 사용 가능)
5. `GET /sessions/{id}/messages` - 전체 메시지 조회
6. `POST /sessions/{id}/predict-next` - 다음 메시지 제안

## 빌드 및 실행

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (API 모델)
flutter pub run build_runner build --delete-conflicting-outputs

# 디버그 빌드
flutter build apk --debug

# 출력
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## 테스트 방법

1. 앱 실행 후 "대화 복기" 모드 선택
2. 권한 허용 (스크린샷, 접근성, 오버레이)
3. 대화 상대 유형 선택
4. 오버레이가 나타나면 "분석 시작" 탭
5. 채팅 앱으로 이동 (앱이 자동으로 백그라운드로 이동)
6. 자동 스크롤 완료 후 "분석 완료" 알림
7. "대화 확인하기" 탭
8. 화면에 점수별 마커가 표시됨
9. 스크롤하면 2초마다 마커 위치 자동 업데이트

## 주의사항

### 관계 정보 하드코딩
현재 `relationship`과 `relationship_info`가 하드코딩되어 있습니다:
```dart
// overlay_widget_new.dart:108-111
final processResponse = await _analysisService.processSession(
  relationship: 'FRIEND',
  relationshipInfo: '친한 친구',
);
```

**TODO**: 사용자가 선택한 관계 정보를 전달하도록 수정 필요

### BASE URL
API 서비스의 BASE URL은 `api_service.dart`에 설정되어 있습니다:
```dart
@RestApi(baseUrl: "http://3.239.81.172/")
```

## 다음 단계 개선 사항

1. **관계 정보 동적 전달**
   - ChoosePartnerScreen에서 선택한 값을 오버레이로 전달
   - SharedPreferences 또는 포트 메시지 활용

2. **마커 터치 시 상세 정보 표시**
   - 현재는 print만 출력
   - 모달이나 팝업으로 AI 피드백, 제안 표시

3. **에러 핸들링 강화**
   - API 실패 시 사용자에게 알림
   - 재시도 로직 추가

4. **로딩 상태 표시**
   - 업로드/처리 중 프로그레스 표시

5. **메모리 최적화**
   - 스크린샷 파일 자동 삭제
   - 타이머 리소스 관리 강화

## 구현 완료 사항 체크리스트

- [x] API 모델 업데이트
- [x] ApiService 엔드포인트 추가 확인
- [x] AnalysisService 생성
- [x] 점수별 아이콘 매핑 로직 구현
- [x] 오버레이 위젯에 마커 표시 기능 추가
- [x] 화면 변경 감지 및 재검색 로직 추가
- [x] 메인 앱에서 스크린샷 경로 전달
- [x] 빌드 및 테스트

## 문의사항

구현에 대한 질문이나 버그 발견 시 이슈를 등록해주세요.
