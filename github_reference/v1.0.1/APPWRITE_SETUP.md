# AppWrite 설정 가이드

이 문서는 TThing 앱을 위한 AppWrite 백엔드 설정 방법을 안내합니다.

## 📋 목차

1. [프로젝트 설정](#1-프로젝트-설정)
2. [Database 설정](#2-database-설정)
3. [Storage 설정](#3-storage-설정)
4. [Push Notification 설정](#4-push-notification-설정)
5. [Cloud Functions 구현](#5-cloud-functions-구현)

---

## 1. 프로젝트 설정

### 1.1 AppWrite 프로젝트 생성

1. [AppWrite Cloud Console](https://cloud.appwrite.io/)에 접속
2. **Create Project** 클릭
3. 프로젝트 이름: `tthing` (또는 원하는 이름)
4. 프로젝트 생성 후 **Project ID** 복사

### 1.2 iOS 플랫폼 추가

1. 프로젝트 대시보드에서 **Settings** → **Platforms** 이동
2. **Add Platform** → **Apple iOS** 선택
3. 다음 정보 입력:
   - **Name**: TThing iOS
   - **Bundle ID**: `com.sookim.tthing`
4. **Next** 클릭 후 완료

### 1.3 앱에 Project ID 설정

`Tthing/Tthing/Utilities/Constants.swift` 파일에서 Project ID 업데이트:

```swift
enum AppConfiguration {
  static let appWriteEndpoint = "https://nyc.cloud.appwrite.io/v1"
  static let appWriteProjectID = "YOUR_PROJECT_ID_HERE"  // 복사한 Project ID
  static let bundleID = "com.sookim.tthing"
}
```

---

## 2. Database 설정

### 2.1 Database 생성

1. 콘솔에서 **Databases** 탭 이동
2. **Create Database** 클릭
3. Database ID: `tthing-db` (또는 `690440aa000e11cea0dd` 사용)
4. Database Name: `TThing Database`

### 2.2 Collection 생성

#### Collection 1: `products` (제품 정보)

**Attributes (필드):**

| Attribute Key | Type | Size | Required | Default |
|--------------|------|------|----------|---------|
| id | String | 255 | Yes | - |
| name | String | 255 | Yes | - |
| category | String | 100 | Yes | - |
| startDate | String | 50 | Yes | - |
| recommendedLifespan | Integer | - | Yes | - |
| photoURL | String | 500 | No | - |
| notificationOffset | Integer | - | Yes | -7 |
| isCompleted | Boolean | - | Yes | false |
| createdAt | String | 50 | Yes | - |
| updatedAt | String | 50 | Yes | - |
| userID | String | 255 | Yes | - |

**Indexes:**
- `userID_idx`: Attribute: `userID`, Type: Key, Order: ASC
- `isCompleted_idx`: Attribute: `isCompleted`, Type: Key

**Permissions:**
- Create: `users`
- Read: `users`
- Update: `users`
- Delete: `users`

---

#### Collection 2: `categories` (카테고리 정보)

**Attributes:**

| Attribute Key | Type | Size | Required | Default |
|--------------|------|------|----------|---------|
| id | String | 255 | Yes | - |
| name | String | 100 | Yes | - |
| iconName | String | 50 | Yes | - |
| recommendedLifespan | Integer | - | Yes | 90 |
| isCustom | Boolean | - | Yes | false |
| createdBy | String | 255 | No | - |

**Indexes:**
- `isCustom_idx`: Attribute: `isCustom`, Type: Key

**Permissions:**
- Create: `users`
- Read: `any` (모든 사용자가 카테고리 조회 가능)
- Update: `users`
- Delete: `users`

---

#### Collection 3: `device_tokens` (디바이스 토큰)

**Attributes:**

| Attribute Key | Type | Size | Required | Default |
|--------------|------|------|----------|---------|
| deviceToken | String | 500 | Yes | - |
| userID | String | 255 | Yes | - |
| platform | String | 20 | Yes | ios |
| updatedAt | String | 50 | Yes | - |

**Indexes:**
- `userID_idx`: Attribute: `userID`, Type: Key, Order: ASC
- `deviceToken_idx`: Attribute: `deviceToken`, Type: Key

**Permissions:**
- Create: `users`
- Read: `users`
- Update: `users`
- Delete: `users`

---

#### Collection 4: `notification_schedules` (알림 스케줄)

**Attributes:**

| Attribute Key | Type | Size | Required | Default |
|--------------|------|------|----------|---------|
| productId | String | 255 | Yes | - |
| productName | String | 255 | Yes | - |
| notificationDate | String | 50 | Yes | - |
| userID | String | 255 | Yes | - |
| isProcessed | Boolean | - | Yes | false |
| createdAt | String | 50 | Yes | - |

**Indexes:**
- `productId_idx`: Attribute: `productId`, Type: Key, Order: ASC
- `userID_idx`: Attribute: `userID`, Type: Key
- `isProcessed_idx`: Attribute: `isProcessed`, Type: Key
- `notificationDate_idx`: Attribute: `notificationDate`, Type: Key, Order: ASC

**Permissions:**
- Create: `users`
- Read: `users`
- Update: `users`
- Delete: `users`

---

## 3. Storage 설정

### 3.1 Storage Bucket 생성

1. 콘솔에서 **Storage** 탭 이동
2. **Create Bucket** 클릭
3. Bucket ID: `product-photos` (또는 `690440d70011343b6079` 사용)
4. Bucket Name: `Product Photos`

### 3.2 Bucket 설정

**File Security:**
- File Security: **Enabled**
- Maximum File Size: `10 MB` (10485760 bytes)
- Allowed File Extensions: `jpg, jpeg, png, heic`

**Permissions:**
- Create: `users`
- Read: `users`
- Update: `users`
- Delete: `users`

---

## 4. Push Notification 설정

### 4.1 APNs 인증서 준비

1. Apple Developer 계정에서 APNs 인증키(.p8) 생성
2. 다음 정보 기록:
   - Key ID
   - Team ID
   - Bundle ID: `com.sookim.tthing`

### 4.2 AppWrite Messaging 설정

1. AppWrite 콘솔에서 **Messaging** 탭 이동
2. **Create Provider** 클릭
3. Provider Type: **APNS** 선택
4. 다음 정보 입력:
   - Provider Name: `TThing iOS Push`
   - Auth Key (.p8 파일 업로드)
   - Key ID
   - Team ID
   - Bundle ID: `com.sookim.tthing`
5. Provider 저장

### 4.3 현재 구현 상태

**✅ 구현 완료:**
- 디바이스 토큰 등록 (`PushNotificationService`)
- 로컬 알림 스케줄링 (`NotificationService`)
- Database에 알림 스케줄 저장 (`AppWriteService`)

**⚠️ 미구현 / 개선 필요:**
- AppWrite Cloud Function을 통한 실제 푸시 발송
- Messaging API를 사용한 푸시 전송
- 스케줄된 알림 자동 발송 시스템

---

## 5. Cloud Functions 구현

### 5.1 필요성

현재 앱은 `notification_schedules` Collection에 알림 스케줄만 저장합니다. 실제로 푸시 알림을 발송하려면 **AppWrite Cloud Function**이 필요합니다.

### 5.2 Cloud Function 생성

1. AppWrite 콘솔에서 **Functions** 탭 이동
2. **Create Function** 클릭
3. Function Name: `send-scheduled-notifications`
4. Runtime: **Node.js 18** 선택

### 5.3 Function 코드 예시

```javascript
const sdk = require('node-appwrite');

module.exports = async ({ req, res, log, error }) => {
  const client = new sdk.Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const databases = new sdk.Databases(client);
  const messaging = new sdk.Messaging(client);

  try {
    // 현재 시간 기준으로 발송할 알림 조회
    const now = new Date().toISOString();

    const schedules = await databases.listDocuments(
      'tthing-db',  // Database ID
      'notification_schedules',  // Collection ID
      [
        sdk.Query.equal('isProcessed', false),
        sdk.Query.lessThanEqual('notificationDate', now)
      ]
    );

    log(`Found ${schedules.documents.length} notifications to send`);

    // 각 스케줄에 대해 푸시 발송
    for (const schedule of schedules.documents) {
      const userID = schedule.userID;

      // 디바이스 토큰 조회
      const tokens = await databases.listDocuments(
        'tthing-db',
        'device_tokens',
        [sdk.Query.equal('userID', userID)]
      );

      if (tokens.documents.length === 0) {
        log(`No device token for user ${userID}`);
        continue;
      }

      const deviceToken = tokens.documents[0].deviceToken;

      // 푸시 알림 발송
      await messaging.createPush(
        sdk.ID.unique(),
        `${schedule.productName} 교체할 시간이에요! 🧼`,
        schedule.productName,
        [userID],
        {
          productId: schedule.productId,
          type: 'replacement_reminder'
        }
      );

      // 스케줄을 처리됨으로 표시
      await databases.updateDocument(
        'tthing-db',
        'notification_schedules',
        schedule.$id,
        { isProcessed: true }
      );

      log(`Sent notification to ${userID} for product ${schedule.productName}`);
    }

    return res.json({ success: true, sent: schedules.documents.length });
  } catch (err) {
    error(`Error sending notifications: ${err.message}`);
    return res.json({ success: false, error: err.message }, 500);
  }
};
```

### 5.4 Environment Variables 설정

Function 설정에서 다음 환경 변수 추가:

- `APPWRITE_ENDPOINT`: `https://nyc.cloud.appwrite.io/v1`
- `APPWRITE_PROJECT_ID`: (프로젝트 ID)
- `APPWRITE_API_KEY`: (Settings → API Keys에서 생성)

### 5.5 Cron Schedule 설정

1. Function 설정에서 **Execute** 탭 이동
2. **Add Schedule** 클릭
3. Schedule: `*/15 * * * *` (15분마다 실행)
4. 저장

---

## 6. 검증 및 테스트

### 6.1 Database 연결 테스트

앱에서 제품을 등록하고 AppWrite 콘솔의 `products` Collection에서 데이터 확인

### 6.2 Storage 테스트

제품 사진을 업로드하고 AppWrite 콘솔의 `product-photos` Bucket에서 파일 확인

### 6.3 Push Notification 테스트

1. 앱 실행 시 디바이스 토큰이 `device_tokens` Collection에 저장되는지 확인
2. 제품 등록 시 `notification_schedules` Collection에 스케줄이 생성되는지 확인
3. Cloud Function 수동 실행하여 푸시 발송 테스트

---

## 7. 트러블슈팅

### 문제: 디바이스 토큰이 등록되지 않음

**해결:**
1. Info.plist에 `NSUserNotificationsUsageDescription` 추가 확인
2. 앱에서 알림 권한 요청 확인
3. AppDelegate의 `didRegisterForRemoteNotificationsWithDeviceToken` 호출 확인

### 문제: 이미지가 로드되지 않음

**해결:**
1. Storage Bucket의 Read 권한 확인
2. `AppWriteService.getFileData()` 메서드가 올바르게 호출되는지 확인
3. fileId가 정확한지 확인

### 문제: Cloud Function이 실행되지 않음

**해결:**
1. Function의 환경 변수 설정 확인
2. API Key 권한 확인 (Databases, Messaging 권한 필요)
3. Function 로그 확인

---

## 8. 보안 권장사항

1. **API Keys**: 절대 클라이언트 코드에 노출하지 말 것 (Cloud Function에서만 사용)
2. **Permissions**: Collection/Bucket 권한을 최소 권한 원칙에 따라 설정
3. **HTTPS**: 모든 통신은 HTTPS를 통해 암호화
4. **Rate Limiting**: AppWrite Console에서 Rate Limit 설정 고려

---

**Last Updated**: 2025-10-31
**AppWrite Version**: 1.4.x
**TThing App Version**: 1.0.0
