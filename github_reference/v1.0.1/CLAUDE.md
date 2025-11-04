# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

TThing은 일상 소모품(칫솔, 수건, 면도날 등)의 교체 주기를 관리하는 iOS 네이티브 앱입니다. 카테고리별로 권장 사용기한이 설정되어 있으며, 교체 시기에 푸시 알림을 발송합니다.

## 기술 스택

- **iOS 16.0+**, SwiftUI, Swift 5.9+
- **AppWrite SDK 13.3.1**: Auth, Databases (TablesDB), Storage, Messaging
- **Architecture**: MVVM + Clean Architecture
- **상태 관리**: Combine, @Published, @Observable

## 프로젝트 구조

```
Tthing/Tthing/
├── App/                    # TthingApp.swift (진입점), ContentView.swift
├── Models/                 # Product, Category, User (Codable 구조체)
├── Views/                  # SwiftUI 뷰 (Auth, Home, Product, Settings)
├── ViewModels/             # AuthViewModel, ProductListViewModel 등
├── Services/               # AppWriteService, ProductService, NotificationService 등
└── Utilities/              # Constants.swift (AppConfiguration), Extensions
```

**핵심 구조**:
- `Product` 모델: AppWrite 서버 저장용 Codable 구조체 (일반 struct)
- `Category` 모델: 하드코딩된 기본 카테고리 + 사용자 정의 카테고리 지원
- `AppWriteService`: 싱글톤으로 Auth, TablesDB, Storage 통합 관리
- `Constants.swift`: API 키, 엔드포인트, DB/Collection ID 등 중앙 관리

## 빌드 및 개발 명령어

### Xcode 프로젝트 열기
```bash
open Tthing/Tthing.xcodeproj
```

### 빌드 및 실행
```bash
# Debug 빌드 (시뮬레이터)
xcodebuild -project Tthing/Tthing.xcodeproj -scheme Tthing -destination 'platform=iOS Simulator,name=iPhone 15' build

# Release 빌드
xcodebuild -project Tthing/Tthing.xcodeproj -scheme Tthing -configuration Release build
```

### 테스트
```bash
# 유닛 테스트 실행
xcodebuild test -project Tthing/Tthing.xcodeproj -scheme Tthing -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 코드 품질 검사
```bash
# SwiftLint 검사 (경고/에러 확인)
swiftlint

# SwiftLint 자동 수정
swiftlint --fix

# SwiftFormat 적용 (자동 포맷팅)
swiftformat Tthing/Tthing/
```

### 패키지 의존성
```bash
# Swift Package 의존성 확인
xcodebuild -project Tthing/Tthing.xcodeproj -scheme Tthing -showBuildSettings | grep PACKAGE_RESOURCE_BUNDLE_NAME
```

## 아키텍처 원칙

### MVVM + Clean Architecture

```
Views (SwiftUI)
    ↓ 바인딩 (@Published, @ObservedObject)
ViewModels (비즈니스 로직, 상태 관리)
    ↓ 의존성 주입
Services (외부 API, 데이터 접근)
    ↓
Models (Codable 데이터 구조)
```

**계층별 책임**:
1. **Views**: UI 렌더링, 사용자 인터랙션 → ViewModel 바인딩
2. **ViewModels**: 비즈니스 로직, @Published 상태 관리, Services 호출
3. **Services**: AppWrite API 통신, 로컬 알림 스케줄링, 파일 저장
4. **Models**: Codable 준수 데이터 구조 (Product, Category, User)

### 데이터 저장 전략

- **로그인 사용자**: AppWrite TablesDB에 서버 저장 (ProductService 사용)
- **비로그인 사용자**: 현재 미지원 (향후 로컬 저장소 구현 예정)
- **사진**: AppWrite Storage에 업로드 후 fileId를 Product.photoURL에 저장
- **카테고리**: Category.defaultCategories의 하드코딩된 기본값 사용 + AppWrite DB의 사용자 정의 카테고리

## 주요 기능 구현

### 1. 인증 (AuthViewModel + AppWriteService)
- Apple 로그인: `account.createOAuth2Token(provider: .apple)`
- 이메일/비밀번호: `account.create()`, `account.createEmailPasswordSession()`
- 세션 관리: `account.getSession(sessionId: "current")`

### 2. 제품 등록 플로우
```
CategoryPickerView (카테고리 선택)
    ↓
Category.recommendedLifespan 자동 설정 (하드코딩된 기본값)
    ↓
AddProductView (사용자가 기한 직접 수정 가능)
    ↓
PhotoPicker (선택 사항)
    ↓
ProductService.createProduct() → AppWriteService.createRow()
```

**권장 사용기한 설정 방식:**
- 기본 카테고리 선택 시: 하드코딩된 기본값 자동 설정 (예: 칫솔 90일)
- 사용자 정의 카테고리: 사용자가 직접 입력한 값 사용
- 제품 등록 화면에서 언제든지 수정 가능

### 3. 알림 시스템
- **로컬 알림**: NotificationService.scheduleNotification() → UNUserNotificationCenter
- **서버 푸시**: AppWriteService.scheduleNotification() → AppWrite Messaging
- **기본 설정**: 교체일 7일 전 (D-7), Constants.defaultNotificationOffset

### 4. AppWrite 통합
- **TablesDB 구조**: `tablesDB.createRow()`, `listRows()`, `updateRow()`, `deleteRow()`
- **Database/Table ID**: Constants.swift에서 중앙 관리 (databaseID, productsCollectionID 등)
- **Storage**:
  - 업로드: `storage.createFile()` - Data를 업로드하고 fileId 반환
  - 조회: `storage.getFileView()` - fileId로 ByteBuffer 반환 → Data로 변환
  - AppWriteImageView에서 Data를 UIImage로 변환하여 표시

## 코드 컨벤션 (SWIFT_CODE_CONVENTION.md)

**핵심 규칙**:
- **들여쓰기**: 2 spaces (탭 금지)
- **줄 길이**: 100자 권장, 120자 초과 금지
- **네이밍**: UpperCamelCase (타입), lowerCamelCase (변수/함수)
- **Access Control**: 기본 private, 필요시 internal/public
- **self**: 필요한 경우만 명시 (클로저, 프로퍼티명 충돌 시)
- **MARK**: `// MARK: - Section` (대제목), `// MARK: Section` (소제목)

**SwiftLint/SwiftFormat 설정**: `.swiftlint.yml`, `.swiftformat` 파일 참조

## AppWrite 설정 (Tthing/Tthing/Info.plist)

**URL Scheme** (OAuth 콜백):
```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>appwrite-callback-{ProjectID}</string>
</array>
```

**권한 설정**:
- `NSPhotoLibraryUsageDescription`: 제품 사진 등록
- `NSUserNotificationsUsageDescription`: 교체 시기 알림

## 개발 시 주의사항

### API Key 관리
- **현재 상태**: `Constants.swift`에 하드코딩되어 있음 (개발 단계)
- **TODO**: 프로덕션 배포 전 `.gitignore` 추가 또는 환경 변수로 이동

### Product 모델
- **주의**: `Product`는 일반 `struct`이며, SwiftData `@Model` 사용하지 않음
- **AppWrite 변환**: `toDictionary()`, `from(dictionary:)` 메서드로 수동 직렬화

### 에러 처리
- `ErrorMessages` enum (Constants.swift) 사용
- `do-catch`로 async throws 처리, 사용자에게 Alert 표시

### 알림 권한
- 앱 실행 시 `UNUserNotificationCenter.current().requestAuthorization()` 필수
- `PushNotificationService.shared.setupNotificationCategories()` 호출 (AppDelegate)

## 일반적인 작업

### 새로운 View 추가
1. `Tthing/Tthing/Views/` 하위에 SwiftUI 파일 생성
2. ViewModel 필요 시 `ViewModels/` 추가
3. MARK 주석으로 섹션 구분 (`// MARK: - Properties`, `// MARK: - Body` 등)
4. 네이밍: `{Feature}View.swift`, `{Feature}ViewModel.swift`

### AppWrite 새 Collection 추가
1. AppWrite 콘솔에서 Collection 생성 → ID 복사
2. `Constants.swift`에 `{collectionName}CollectionID` 추가
3. `AppWriteService`에 CRUD 메서드 활용 (`createRow`, `listRow` 등)
4. Model 구조체 정의 + `toDictionary()`, `from(dictionary:)` 구현

### 새로운 카테고리 추가
- **기본 카테고리**: `Category.swift`의 `defaultCategories` 배열에 추가
- **사용자 정의 카테고리**: CategoryService를 통해 DB에 저장

## 테스트 전략

- **현재 상태**: 유닛 테스트 미구축
- **향후 계획**: ViewModel 로직, Service API 호출 Mock 테스트 추가

## 참고 자료

- PRD: `PRD.md` (한글 요구사항 명세)
- AppWrite 설정: `APPWRITE_SETUP.md` (DB/Storage/Push Notification 설정 가이드)
- [AppWrite Documentation](https://appwrite.io/docs)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

---

**Last Updated**: 2025-10-31
**Bundle ID**: com.sookim.tthing
**Min iOS Version**: 16.0
