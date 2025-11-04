# Swift 코드 컨벤션 가이드

## 목차

1. [소개](#소개)
2. [코드 레이아웃](#코드-레이아웃)
3. [네이밍](#네이밍)
4. [코드 구조](#코드-구조)
5. [타입](#타입)
6. [클로저](#클로저)
7. [제어문](#제어문)
8. [옵셔널](#옵셔널)
9. [에러 처리](#에러-처리)
10. [주석과 문서화](#주석과-문서화)
11. [프로그래밍 권장사항](#프로그래밍-권장사항)

---

## 소개

이 문서는 Swift 코드를 일관성 있고 가독성 높게 작성하기 위한 가이드입니다. Apple의 Swift API Design Guidelines, Google Swift Style Guide, Airbnb Swift Style Guide, StyleShare Swift Style Guide를 종합하여 작성되었습니다.

### 기본 원칙

- **사용 시점에서의 명확성(Clarity at the point of use)**이 가장 중요한 목표입니다
- **간결함보다 명확함**을 우선시합니다
- **일관성**을 유지합니다
- **타입 추론**을 적극 활용합니다

---

## 코드 레이아웃

### 들여쓰기 및 공백

- **2개의 space**를 사용하여 들여쓰기합니다 (탭 사용 금지)
- 파일 끝에는 항상 빈 줄이 있어야 합니다
- 후행 공백(trailing whitespace)은 제거합니다

```swift
// 좋은 예
func greet(name: String) {
  print("Hello, \(name)!")
}

// 나쁜 예 (탭 사용)
func greet(name: String) {
→→print("Hello, \(name)!")
}
```

### 줄 길이

- 한 줄의 최대 길이는 **100자**를 권장합니다
- 120자를 초과하지 않도록 합니다
- URL이나 긴 문자열 등 예외 상황은 허용됩니다

### 줄바꿈

#### 함수 정의

함수 정의가 최대 길이를 초과하는 경우 파라미터별로 줄바꿈합니다.

```swift
// 좋은 예
func tableView(
  _ tableView: UITableView,
  cellForRowAt indexPath: IndexPath
) -> UITableViewCell {
  // ...
}

// 또는 한 줄에 작성 가능한 경우
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  // ...
}
```

#### 함수 호출

```swift
// 좋은 예
let actionSheet = UIAlertController(
  title: "알림",
  message: "정말 삭제하시겠습니까?",
  preferredStyle: .actionSheet
)

// 클로저가 2개 이상인 경우 무조건 줄바꿈
UIView.animate(
  withDuration: 0.3,
  animations: {
    self.view.alpha = 0
  },
  completion: { _ in
    self.view.removeFromSuperview()
  }
)
```

#### if/guard let 구문

```swift
// 좋은 예
if let user = self.fetchUser(),
   let name = user.name,
   user.isActive {
  print("Hello, \(name)")
}

guard let user = self.fetchUser(),
      let name = user.name,
      user.isActive
else {
  return
}
```

### 중괄호

- K&R 스타일을 따릅니다 (여는 중괄호는 같은 줄에, 닫는 중괄호는 새로운 줄에)
- 단일 구문의 경우 한 줄로 작성 가능합니다

```swift
// 좋은 예
if condition {
  doSomething()
}

guard let value = optionalValue else { return }

// 나쁜 예
if condition
{
  doSomething()
}
```

### 빈 줄

- MARK 구문 위아래에는 빈 줄을 넣습니다
- 논리적으로 구분되는 코드 블록 사이에는 빈 줄을 넣습니다
- 연속된 빈 줄은 1줄로 제한합니다

```swift
// MARK: - View Lifecycle

override func viewDidLoad() {
  super.viewDidLoad()
  setupUI()
}

// MARK: - Actions

@objc private func buttonTapped() {
  // ...
}
```

### Import 정렬

- 알파벳 순으로 정렬합니다
- 시스템 프레임워크를 먼저, 서드파티 프레임워크는 빈 줄 후에 작성합니다

```swift
import Foundation
import UIKit

import Alamofire
import SnapKit
```

---

## 네이밍

### 일반 원칙

- **UpperCamelCase**: 타입, 프로토콜
- **lowerCamelCase**: 변수, 상수, 함수, 프로퍼티

### 타입 네이밍

```swift
// 좋은 예
class UserManager { }
struct UserProfile { }
enum NetworkError { }
protocol Drawable { }

// 나쁜 예
class userManager { }  // 소문자 시작
class UserMgr { }      // 불필요한 축약
```

### 함수 네이밍

- 함수 이름 앞에 `get`을 붙이지 않습니다
- 동사로 시작합니다
- 명확하고 설명적인 이름을 사용합니다

```swift
// 좋은 예
func name(for user: User) -> String
func fetchUserProfile(completion: @escaping (User?) -> Void)

// 나쁜 예
func getName(for user: User) -> String
func userProfile() -> User  // 동사가 없음
```

### 액션 함수

- **주어 + 동사 + 목적어** 형태를 사용합니다
- `did`는 이미 발생한 이벤트, `will`은 발생할 이벤트, `should`는 Bool 반환

```swift
// 좋은 예
func loginButtonDidTap()
func scrollViewWillBeginDragging()
func shouldRefreshData() -> Bool

// 나쁜 예
func login()        // 주어가 없음
func tapped()       // 목적어가 없음
```

### 변수와 상수

```swift
// 좋은 예
let maximumRetryCount = 3
var currentPage = 1

// 나쁜 예
let MAX_RETRY = 3           // snake_case
let kMaximumRetryCount = 3  // Hungarian notation
```

### 열거형

```swift
// 좋은 예
enum Result {
  case success
  case failure
}

enum HTTPStatus: Int {
  case ok = 200
  case notFound = 404
  case serverError = 500
}

// 나쁜 예
enum Result {
  case Success  // 대문자 시작
  case Failure
}
```

### 약어

- 약어로 시작하는 경우 소문자로, 그 외의 경우 대문자로 표기합니다

```swift
// 좋은 예
let userID: Int
let htmlString: String
let urlSession: URLSession
let pngImage: UIImage

// 나쁜 예
let userId: Int
let HTMLString: String
let URLSession: URLSession
```

### Delegate

- Delegate 메서드는 프로토콜명으로 네임스페이스를 구분합니다

```swift
// 좋은 예
protocol UserCellDelegate: AnyObject {
  func userCellDidTapProfileImage(_ cell: UserCell)
  func userCell(_ cell: UserCell, didTapFollowButton isFollowing: Bool)
}

// 나쁜 예
protocol UserCellDelegate: AnyObject {
  func didTapProfileImage()  // 네임스페이스 없음
  func followButtonTapped(isFollowing: Bool)
}
```

---

## 코드 구조

### 파일 구조

```swift
// Import
import UIKit

// MARK: - Type Definition

final class ProfileViewController: UIViewController {

  // MARK: - Constants

  private enum Metric {
    static let padding: CGFloat = 16
    static let imageSize: CGFloat = 80
  }

  private enum Color {
    static let background = UIColor.white
    static let text = UIColor.black
  }

  // MARK: - Properties

  private let profileImageView = UIImageView()
  private let nameLabel = UILabel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  // MARK: - Setup

  private func setupUI() {
    // ...
  }

  // MARK: - Actions

  @objc private func editButtonTapped() {
    // ...
  }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
  // ...
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
  // ...
}
```

### Extension을 통한 프로토콜 채택

```swift
// 좋은 예
class MyViewController: UIViewController {
  // class 구현
}

extension MyViewController: UITableViewDelegate {
  // delegate 구현
}

extension MyViewController: UITableViewDataSource {
  // data source 구현
}

// 나쁜 예
class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  // 모든 것을 한 곳에
}
```

### 타입 추론 활용

```swift
// 좋은 예
let message = "Hello"
let count = 5
let numbers = [1, 2, 3]

// 명시가 필요한 경우
let identifier: Int64 = 12345
let view: UIView = UIButton()

// 나쁜 예 (불필요한 명시)
let message: String = "Hello"
let count: Int = 5
```

---

## 타입

### Array, Dictionary, Optional

- 축약형을 사용합니다

```swift
// 좋은 예
var names: [String] = []
var userInfo: [String: Any] = [:]
var age: Int?

// 나쁜 예
var names: Array<String> = []
var userInfo: Dictionary<String, Any> = [:]
var age: Optional<Int>
```

### 타입 어노테이션

- 빈 배열이나 딕셔너리를 초기화할 때는 타입을 명시합니다

```swift
// 좋은 예
let names: [String] = []
let userInfo: [String: Any] = [:]

// 나쁜 예
let names = [String]()
let userInfo = [String: Any]()
```

---

## 클로저

### 파라미터와 리턴 타입

```swift
// 좋은 예
let completion: () -> Void
let transform: (Int) -> String

// 나쁜 예
let completion: () -> ()
let transform: (Int) -> String?  // 문맥에 따라 생략 가능
```

### 클로저 정의

```swift
// 좋은 예 - 타입 추론 활용
numbers.map { $0 * 2 }

numbers.filter { number in
  return number > 5
}

// 괄호 생략
UIView.animate(withDuration: 0.3) {
  self.view.alpha = 0
}

// 나쁜 예
numbers.map { (number: Int) -> Int in
  return number * 2
}
```

### Trailing Closure

- 마지막 파라미터가 클로저인 경우 trailing closure 문법을 사용합니다
- 클로저가 2개 이상인 경우 모두 레이블과 함께 작성합니다

```swift
// 좋은 예
UIView.animate(withDuration: 0.3) {
  self.view.alpha = 0
}

// 클로저가 2개 이상
UIView.animate(
  withDuration: 0.3,
  animations: {
    self.view.alpha = 0
  },
  completion: { _ in
    self.view.removeFromSuperview()
  }
)
```

---

## 제어문

### guard를 활용한 Early Exit

```swift
// 좋은 예
func process(user: User?) {
  guard let user = user else {
    return
  }

  guard user.isActive else {
    return
  }

  // 메인 로직
  print("Processing user: \(user.name)")
}

// 나쁜 예
func process(user: User?) {
  if let user = user {
    if user.isActive {
      print("Processing user: \(user.name)")
    }
  }
}
```

### for-where

```swift
// 좋은 예
for user in users where user.isActive {
  print(user.name)
}

// 나쁜 예
for user in users {
  if user.isActive {
    print(user.name)
  }
}
```

### switch

```swift
// 좋은 예
switch result {
case .success(let value):
  print("Success: \(value)")
case .failure(let error):
  print("Error: \(error)")
}

// 범위를 활용
switch age {
case 0..<13:
  print("Child")
case 13..<20:
  print("Teenager")
default:
  print("Adult")
}
```

---

## 옵셔널

### 옵셔널 바인딩

```swift
// 좋은 예
if let name = optionalName {
  print(name)
}

// 여러 개의 옵셔널
if let name = optionalName,
   let age = optionalAge {
  print("\(name), \(age)")
}

// 나쁜 예
if let name = optionalName {
  if let age = optionalAge {
    print("\(name), \(age)")
  }
}
```

### nil 체크

```swift
// 좋은 예
if value != nil {
  print("Value exists")
}

// 나쁜 예 (불필요한 언래핑)
if let _ = value {
  print("Value exists")
}
```

### 강제 언래핑 주의

```swift
// 피해야 할 경우
let value = dict["key"]!  // 위험

// 허용되는 경우 (명확한 이유가 있을 때)
// 이 값은 항상 존재하므로 안전합니다
let homeDirectory = FileManager.default.urls(
  for: .documentDirectory,
  in: .userDomainMask
).first!
```

### Implicitly Unwrapped Optional

- 가능한 한 사용을 피합니다
- IBOutlet이나 생명주기가 보장되는 UI 요소에만 사용합니다

```swift
// 허용되는 경우
@IBOutlet private var tableView: UITableView!

// 피해야 할 경우
var name: String!  // Optional<String> 사용
```

---

## 에러 처리

### Error 타입 정의

```swift
// 좋은 예
enum NetworkError: Error {
  case invalidURL
  case noConnection
  case timeout
  case serverError(statusCode: Int)
}

struct ValidationError: Error {
  let field: String
  let message: String
}
```

### do-catch

```swift
// 좋은 예
do {
  let data = try loadData()
  process(data)
} catch NetworkError.noConnection {
  showNoConnectionAlert()
} catch NetworkError.serverError(let code) {
  showServerError(code: code)
} catch {
  showGenericError(error)
}
```

### try?, try!

```swift
// try? - 에러를 무시하고 nil 반환
let data = try? loadData()

// try! - 절대 실패하지 않는다고 확신할 때만 사용
let regex = try! NSRegularExpression(pattern: "[0-9]+")
```

---

## 주석과 문서화

### 문서 주석

```swift
/// 사용자 프로필을 가져옵니다.
///
/// - Parameters:
///   - userID: 사용자 고유 식별자
///   - completion: 프로필 로드 완료 후 호출되는 클로저
/// - Returns: 취소 가능한 요청 객체
func fetchUserProfile(
  userID: String,
  completion: @escaping (Result<User, Error>) -> Void
) -> Cancellable {
  // ...
}
```

### MARK 주석

```swift
// MARK: - Section Title (대제목, 구분선 포함)
// MARK: Section Title (소제목)

// 예시
// MARK: - Constants
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Setup
// MARK: - Actions
// MARK: - Private Methods
```

### 일반 주석

```swift
// 한 줄 주석은 // 를 사용합니다

// 여러 줄 주석도
// 각 줄마다 // 를 사용합니다
// /* */ 스타일은 사용하지 않습니다

// TODO: 추후 구현 필요
// FIXME: 버그 수정 필요
// NOTE: 참고 사항
```

---

## 프로그래밍 권장사항

### let vs var

- 가능한 한 `let`을 사용합니다 (불변성)

```swift
// 좋은 예
let name = "Swift"
let numbers = [1, 2, 3]

// var는 변경이 필요한 경우만
var count = 0
count += 1
```

### self 사용

- 필요한 경우에만 명시합니다
- 클로저 내부나 프로퍼티명이 파라미터와 겹칠 때만 사용합니다

```swift
// 좋은 예
class User {
  let name: String

  init(name: String) {
    self.name = name  // 파라미터와 구분하기 위해 필요
  }

  func greet() {
    print("Hello, \(name)")  // self 불필요
  }
}
```

### Access Control

- 적절한 접근 제어자를 사용합니다
- 기본적으로 internal이므로 명시 생략 가능합니다

```swift
// 좋은 예
public class User {
  public let id: String
  private var password: String

  public init(id: String, password: String) {
    self.id = id
    self.password = password
  }

  private func validatePassword() -> Bool {
    // ...
  }
}
```

### final 키워드

- 상속이 불필요한 클래스는 `final`로 선언합니다

```swift
// 좋은 예
final class UserManager {
  // ...
}
```

### Enum을 활용한 네임스페이스

```swift
// 좋은 예
enum Constants {
  enum UI {
    static let cornerRadius: CGFloat = 8
    static let animationDuration: TimeInterval = 0.3
  }

  enum API {
    static let baseURL = "https://api.example.com"
    static let timeout: TimeInterval = 30
  }
}

// 사용
view.layer.cornerRadius = Constants.UI.cornerRadius
```

### 타입 메서드와 프로퍼티

```swift
// 좋은 예
extension UIColor {
  static let primary = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
  static let secondary = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0)
}

// 사용
view.backgroundColor = .primary
```

### 불필요한 괄호 제거

```swift
// 좋은 예
if condition {
  doSomething()
}

let result = value1 + value2

// 나쁜 예
if (condition) {
  doSomething()
}

let result = (value1 + value2)
```

### 세미콜론

- 사용하지 않습니다

```swift
// 좋은 예
let name = "Swift"
print(name)

// 나쁜 예
let name = "Swift";
print(name);
```

---

## 도구 설정

### SwiftLint 사용

프로젝트에 `.swiftlint.yml` 파일을 추가하여 자동으로 스타일을 검사합니다.

```bash
# 설치 (Homebrew)
brew install swiftlint

# 실행
swiftlint

# 자동 수정
swiftlint --fix
```

### SwiftFormat 사용

코드를 자동으로 포맷팅합니다.

```bash
# 설치 (Homebrew)
brew install swiftformat

# 실행
swiftformat .

# 특정 파일
swiftformat Sources/
```

### Xcode 설정

- **Preferences → Text Editing → Display**
  - Line numbers 활성화
  - Code folding ribbon 활성화
  - Page guide at column: 100

- **Preferences → Text Editing → Indentation**
  - Prefer indent using: Spaces
  - Tab width: 2 spaces
  - Indent width: 2 spaces

---

## 참고 자료

- [Apple Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Google Swift Style Guide](https://google.github.io/swift/)
- [Airbnb Swift Style Guide](https://github.com/airbnb/swift)
- [StyleShare Swift Style Guide](https://github.com/StyleShare/swift-style-guide)
- [Swift.org Documentation](https://swift.org/documentation/)

---

## 버전 정보

- **작성일**: 2025-10-28
- **Swift 버전**: 5.9+
- **업데이트**: 프로젝트 필요에 따라 지속적으로 업데이트
