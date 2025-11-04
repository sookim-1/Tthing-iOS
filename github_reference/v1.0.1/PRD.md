# 📝 iOS 소모품 교체 주기 알리미 (가제) PRD

## 1. 개요 및 목표 (Overview & Objectives)

* **1.1. 앱의 목적:** 사용자들의 일상생활 속에서 사용기한이 정해져 있지 않은 소모품들의 교체 주기를 관리하여, 더 건강하고 편리한 생활을 누릴 수 있도록 돕는다.
* **1.2. 문제 정의 (Problem Statement):** 칫솔, 수건, 면도날 등 많은 일상 소모품은 위생 및 건강상의 이유로 권장 사용 기한이 존재하지만, 사용자들이 이를 인지하거나 기억하기 어렵다.
* **1.3. 해결 방안 (Solution):** 사용자가 제품 카테고리를 지정하면, AI가 해당 카테고리의 일반적인 권장 사용 기한을 자동으로 설정해 준다. 이후 교체 시기가 임박했을 때 알림을 보내 사용자가 잊지 않고 제품을 교체할 수 있도록 돕는다.
* **1.4. 핵심 기능 요약:** 제품 카테고리별 권장 사용기한 자동 계산 및 교체 시기 알림.
* **1.5. 주요 타겟 사용자:** 일상 용품을 체계적으로 관리하고 교체 주기를 챙기고 싶은 사용자.

---

## 2. 주요 기능 및 사용자 스토리 (Features & User Stories)

### 2.1. 핵심 기능: 소모품 등록 (MVP)

* **User Story:** 사용자는 내가 교체 주기를 잊지 않도록, 새로운 소모품을 앱에 쉽고 빠르게 등록할 수 있다.
* **세부 사항:**
    * **등록 방식:** '사진 없이' **[카테고리 선택]**만으로 제품 등록. (사진 등록은 선택 사항)
    * **기준일 설정:** 사용자가 **[기준일]**(예: 구매일, 사용 시작일)을 직접 설정.
    * **카테고리 및 기한 설정:**
        1.  **[기본 카테고리]** 선택 시, AI가 **[권장 사용기한]** 자동 제안 (`Gemini API` 활용).
        2.  사용자는 제안된 기한을 **[직접 수정]** 가능.
    * **사용자 정의 카테고리 (서버 기능):**
        1.  로그인 시, **[새로운 카테고리]** 생성 가능.
        2.  생성된 카테고리는 공유 DB(`AppWrite`)에 저장되어 다른 사용자에게도 노출.

### 2.2. 핵심 기능: 교체 알림

* **User Story:** 사용자는 내가 설정한 교체 시기를 잊지 않도록, 적절한 시점에 앱으로부터 알림을 받을 수 있다.
* **세부 사항:**
    * **알림 시점:** 기본 **[교체일 7일 전(D-7)]** 발송. 사용자가 **[설정]**에서 변경 가능.
    * **알림 내용 및 액션:**
        1.  푸시 알림: `"[제품명] 교체할 시간이에요! 🧼"` (`AppWrite Messaging` 활용).
        2.  알림 탭 시, 해당 **[제품 상세 화면]**으로 이동.

### 2.3. 핵심 기능: 소모품 관리 (메인 화면)

* **User Story:** 사용자는 앱의 메인 화면에서 내가 등록한 모든 소모품의 현황을 한눈에 파악하고 관리할 수 있다.
* **세부 사항:**
    * **UI/UX:** **[갤러리/카드 형태]**로 목록 표시. 사진 미등록 시 **[플레이스홀더 아이콘]** 표시.
    * **정렬:** 기본 **[교체일 임박순]**. **[등록순]**, **[카테고리별 보기]** 옵션 제공.
    * **교체 완료 처리:**
        1.  **[교체 완료]** 버튼 클릭 시, 해당 항목 **[삭제]**.
        2.  삭제 직후, "같은 카테고리의 새 제품을 등록하시겠습니까?" **[확인 팝업]** 노출.

---

## 3. 비기능적 요구사항 (Non-Functional Requirements)

* **3.1. 데이터 저장:**
    * **로그인 사용자:** `AppWrite Databases`를 통해 서버에 저장 및 동기화.
* **3.2. 사용자 계정:** **[Apple로 로그인]**, **[이메일로 로그인]** 지원 (`AppWrite Auth` 활용).
* **3.3. 지원 플랫폼:**
    * **플랫폼:** **[iOS (iPhone) 전용]** 네이티브 앱.
    * **최소 지원 버전:** **[iOS 17.0]** 이상.

---

## 4. 기술 스택 (Technical Stack)

* **4.2. 아키텍처:** View와 모델, 로직은 분리하고 상태 관리 및 비즈니스 로직 구현.
* **4.3. UI 프레임워크:** `SwiftUI`를 사용하여 전체 사용자 인터페이스 구성.
* **4.4. 백엔드 (BaaS):** `AppWrite` 활용
    * **인증 (Auth):** `AppWrite Auth` (Apple/이메일 로그인)
    * **데이터베이스 (DB):** `AppWrite Databases` (제품 정보, 사용자 정의 카테고리 저장)
    * **파일 저장 (Storage):** `AppWrite Storage` (사용자가 등록한 제품 사진 저장)
    * **푸시 알림 (Messaging):** `AppWrite Messaging` (교체 주기 알림 발송)


## 5. 패키지
Appwrite 패키지 : https://github.com/appwrite/sdk-for-apple.git 13.3.1 버전

## 6. Config 설정
Bundle ID : com.sookim.tthing

AppWrite 설정 : 

<key>CFBundleURLTypes</key>
<array>
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>io.appwrite</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>appwrite-callback-6902ef4c002ad1b6c2ad</string>
    </array>
</dict>
</array>

### AppWrite.swift

import Foundation
import Appwrite
import JSONCodable

class Appwrite {
    var client: Client
    var account: Account
    
    public init() {
        self.client = Client()
            .setEndpoint("https://nyc.cloud.appwrite.io/v1")
            .setProject("6902ef4c002ad1b6c2ad")
        
        self.account = Account(client)
    }
    
    public func onRegister(
        _ email: String,
        _ password: String
    ) async throws -> User<[String: AnyCodable]> {
        try await account.create(
            userId: ID.unique(),
            email: email,
            password: password
        )
    }
    
    public func onLogin(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }
    
    public func onLogout() async throws {
        _ = try await account.deleteSession(
            sessionId: "current"
        )
    }
    
}




