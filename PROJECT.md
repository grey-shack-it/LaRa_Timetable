# 라라 시간표 📅

> 복잡한 아이들 학원 시간, 이제 한눈에 쏙!

---

## 프로젝트 개요

아이들의 학원 시간표를 간편하게 관리하는 Flutter 앱.
다자녀 가정도 한 화면에서 모든 아이의 일정을 확인할 수 있다.

- **플랫폼**: Android (iOS 추후 예정)
- **버전**: 1.1.1+6
- **패키지명**: `com.larapapa.timetable`

---

## 핵심 기능

| 기능 | 설명 |
|------|------|
| 📝 시간표 작성 | 요일·시간·아이콘·색상을 선택해 일정 등록 |
| 👨‍👩‍👧‍👦 다자녀 관리 | 아이별 프로필 탭 전환 + "한눈에" 통합 뷰 |
| 📸 이미지 저장 | 앱 로고·QR 합성 후 갤러리 저장 |
| 🔔 알림 | 일정 시작·종료 전 N분 알림 (매주 반복) |
| 🔐 소셜 로그인 | 구글 / 카카오 로그인 |
| 🏫 학원 정보 관리 | 아이별 학원 정보 입력 및 관리 |
| 📞 빠른 연락 | 전화 / 문자 / 카카오 오픈채팅 / 웹사이트 |
| 💰 결제일 알림 | 결제일 N일 전 알림 (시간 설정 가능, 매월 반복) |

---

## 수익화 전략

1. **AdMob 배너 광고** — 하단 고정
2. **소액 인앱 결제** — 결제 시 광고 제거 (예정)

---

## 버전 히스토리

### v1.1.0 (현재)
- 구글 / 카카오 소셜 로그인
- 학원 정보 관리 (추가/편집/삭제)
- 카카오 주소 검색 API 연동
- 전화 / 문자 / 오픈채팅 / 웹사이트 연동
- 결제 주기 개편 (월간/주간/분기/반기/연간)
- 결제일 알림 (시간 설정, 매월 반복)
- 학원비 천단위 콤마 표시
- 드래그 이동 기능 삭제 (UX 개선)
- SafeArea 적용
- Android 15 Edge-to-Edge 대응
- 개인정보처리방침 링크
- 회원 탈퇴 기능

### v1.0.x
- 시간표 작성 / 다자녀 관리 / 이미지 저장 / 알림

---

## 다음 버전 예정 기능 (v1.2.0)

| 기능 | 설명 |
|------|------|
| 📱 홈 화면 위젯 | 오늘 일정 + 학원 정보 한눈에 표시 |

---

## 장기 로드맵

```
현재: 시간표 + 학원 정보 관리 (v1.1.0)
  ↓
다음: 홈 화면 위젯 (v1.2.0)
  ↓
그다음: 학원 정보 교류 커뮤니티
       (개인 정보는 범위로 변환해서 간접 제공
        예: 23,450원 → 2만~3만원대)
  ↓
목표: 학원 정보에 특화된 플랫폼
```

## 커뮤니티 설계 (추후)

### UI 구조
- 학원정보/커뮤니티 토글 스위치로 화면 전환
- 학원 상세창 하단에 커뮤니티 정보 일부 표시 (신규 게시글, 별점 등)

### 커뮤니티 구조
```
지역별 검색
  ↓
과목별 학원 리스트
  ↓
학원별 평가 및 정보 게시판
```

### 개인정보 보호 방식
- 개인 보관: 정확한 수치 (학원비 23,450원)
- 커뮤니티 노출: 범위로 변환 (2만~3만원대)

### 닉네임
- 커뮤니티 활동용 닉네임 설정 (profiles 테이블 nickname 필드)

---

## 기술 스택

| 분류 | 라이브러리 | 버전 | 비고 |
|------|-----------|------|------|
| 상태 관리 | GetX | ^4.7.3 | |
| 로컬 DB | Hive | ^2.2.3 | 시간표 데이터 |
| 서버 DB | Supabase | - | 학원 정보, 로그인 |
| 소셜 로그인 | google_sign_in / kakao_flutter_sdk_user | - | 구글/카카오 |
| 주소 검색 | 카카오 주소 검색 API (WebView) | - | |
| 알림 | flutter_local_notifications | ^21.0.0 | |
| 타임존 | timezone | ^0.11.0 | |
| 광고 | google_mobile_ads | - | |
| 이미지 저장 | screenshot + saver_gallery | - | |
| URL 연동 | url_launcher | - | 전화/문자/웹 |
| WebView | webview_flutter | - | 주소 검색 |

---

## 프로젝트 구조

```
lib/
├── main.dart
├── env.dart                         # API 키 보안 관리 (.gitignore)
├── constants/
│   └── app_colors.dart              # 앱 색상 상수
├── data/
│   ├── schedule.dart                # 일정 데이터 모델
│   ├── schedule.g.dart              # Hive 자동생성 어댑터
│   ├── child_profile.dart           # 아이 프로필 모델
│   └── child_profile.g.dart
├── modules/
│   ├── auth/
│   │   └── login_view.dart          # 로그인 화면
│   ├── academy/
│   │   ├── academy_controller.dart  # 학원정보 로직 (GetX)
│   │   ├── academy_view.dart        # 학원정보 목록 화면
│   │   ├── academy_detail_view.dart # 학원 상세/편집 화면
│   │   └── kakao_address_search.dart # 카카오 주소 검색
│   └── home/
│       ├── home_controller.dart     # 앱 핵심 로직 (GetX)
│       ├── home_view.dart           # 메인 화면
│       └── widgets/
│           ├── time_grid.dart           # 시간 그리드 UI
│           ├── schedule_block.dart      # 일정 블록 UI
│           ├── profile_tab_bar.dart     # 아이 탭 바
│           ├── profile_manage_sheet.dart # 프로필 관리
│           ├── add_schedule_dialog.dart  # 일정 추가
│           ├── edit_schedule_dialog.dart # 일정 수정
│           └── schedule_dialog_helpers.dart # 공통 헬퍼
└── services/
    ├── alarm_service.dart       # 알림 스케줄링 (일정 + 결제일)
    ├── auth_service.dart        # 구글/카카오 로그인
    └── image_save_service.dart  # 이미지 합성·저장
```

---

## 데이터 모델

### Schedule (typeId: 0)

| 필드 | 타입 | 설명 |
|------|------|------|
| title | String | 일정 이름 |
| startTime | DateTime | 시작 시간 |
| endTime | DateTime | 종료 시간 |
| dayOfWeek | int | 요일 (1=월 ~ 7=일) |
| iconName | String? | 아이콘 이름 |
| memo | String | 메모 |
| colorValue | int | 블록 색상 |
| childId | String | 아이 프로필 ID |
| startAlarm | bool | 시작 알람 on/off |
| startAlarmMinutes | int | 시작 N분 전 알람 |
| endAlarm | bool | 종료 알람 on/off |
| endAlarmMinutes | int | 종료 N분 전 알람 |

### ChildProfile (typeId: 1)

| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 고유 ID (timestamp) |
| name | String | 아이 이름 |

### Profiles (Supabase)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | uuid | ✅ | auth.users와 연결 |
| nickname | String | ❌ | 커뮤니티 활동용 닉네임 |
| created_at | timestamp | ✅ | 생성일 |

### AcademyInfo (Supabase)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | uuid | ✅ | 고유 ID |
| user_id | uuid | ✅ | auth.users와 연결 |
| child_id | String | ✅ | 아이 프로필 ID |
| name | String | ✅ | 학원 이름 |
| subject | String | ✅ | 과목명 |
| address_sido | String | ❌ | 시/도 |
| address_sigungu | String | ❌ | 시/군/구 |
| address_dong | String | ❌ | 읍/면/동 |
| address_full | String | ❌ | 전체 주소 |
| address_detail | String | ❌ | 상세 주소 |
| phone | String | ❌ | 전화번호 |
| kakao_openchat | String | ❌ | 카카오 오픈채팅 URL |
| website | String | ❌ | 웹사이트 URL |
| fee | int | ✅ | 학원비 (원 단위) |
| payment_cycle | String | ✅ | 결제 주기 (월간/주간/분기/반기/연간) |
| payment_start_month | int | ❌ | 분기/반기/연간 시작월 |
| payment_day | int | ✅ | 결제일 |
| payment_alarm | bool | ❌ | 결제일 알림 on/off |
| payment_alarm_days | int | ❌ | 결제일 N일 전 알림 (1~7) |
| payment_alarm_hour | int | ❌ | 알림 시각 (시) |
| payment_alarm_minute | int | ❌ | 알림 시각 (분) |
| shuttle_location | String | ❌ | 셔틀 위치 |
| memo | String | ❌ | 학원 메모 |
| created_at | timestamp | ✅ | 생성일 |

---

## 소셜 로그인 설정

### Google
- Google Cloud Console → OAuth 2.0 클라이언트 ID
  - Android (Debug): SHA-1 debug keystore
  - Android (Release): SHA-1 app signing key (Play Console)
- Supabase → Authentication → Providers → Google

### Kakao
- Kakao Developers → 플랫폼 키
  - 네이티브 앱 키: `env.dart`의 `kakaoNativeAppKey`
  - Android 앱 키 해시: debug + release 둘 다 등록
- Supabase → Authentication → Providers → Kakao
  - REST API Key 칸에 **네이티브 앱 키** 입력 (주의!)
  - Client Secret: 카카오 콘솔의 클라이언트 시크릿 코드

---

## 보안 주의사항

`.gitignore`에 등록된 파일들 (새 환경 세팅 시 수동 복사 필요):
```
android/key.properties       # Release 서명 설정
android/app/upload-keystore.jks  # Release 키스토어
lib/env.dart                 # API 키 모음
```

---

## 지원 아이콘

`국어` `영어` `수학` `미술` `태권도` `피아노` `독서` `과학` `학교` `수영` `축구`

---

## 디자인 컬러

| 이름 | 색상코드 | 용도 |
|------|---------|------|
| mainPurple | `#C09FF8` | 버튼, 선택 상태 |
| lightPurple | `#F1EBFF` | 배경 |
| darkPurple | `#9468E6` | 텍스트, 아이콘 |
| gridLine | `#BCA9E1` | 그리드 선 |

---

## 빌드 & 실행

```bash
# 의존성 설치
flutter pub get

# Hive 어댑터 재생성 (모델 변경 시)
dart run build_runner build --delete-conflicting-outputs

# 앱 아이콘 생성
dart run flutter_launcher_icons

# 스플래시 화면 생성
dart run flutter_native_splash:create

# 릴리즈 빌드
flutter build apk --release
```

---

## Android 권한

| 권한 | 용도 |
|------|------|
| POST_NOTIFICATIONS | 알림 표시 |
| SCHEDULE_EXACT_ALARM | 정확한 알람 예약 (API ≤ 32) |
| USE_EXACT_ALARM | 정확한 알람 예약 (API ≥ 33) |
| READ_MEDIA_IMAGES | 갤러리 저장 (API ≥ 33) |
| WRITE_EXTERNAL_STORAGE | 갤러리 저장 (API ≤ 29) |
| RECEIVE_BOOT_COMPLETED | 재부팅 후 알람 복구 |
| INTERNET | 네트워크 통신 |

---

*라라 시간표 — 아이들 일정, 엄마 아빠가 더 편하게* 🐣
