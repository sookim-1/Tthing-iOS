//
//  PushNotificationService.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import UserNotifications

/// AppWrite Push Notification
class PushNotificationService {
  static let shared = PushNotificationService()

  private let notificationCenter = UNUserNotificationCenter.current()
  private let deviceTokenKey = "deviceToken"

  private init() {}

  // MARK: - Device Token

  func saveDeviceToken(_ tokenData: Data) {
    let token = tokenData.map { String(format: "%.2hhx", $0) }.joined()
    UserDefaults.standard.set(token, forKey: deviceTokenKey)
    print("✅ Device token saved: \(token)")
  }

  func getDeviceToken() -> String? {
    UserDefaults.standard.string(forKey: deviceTokenKey)
  }

  func registerDeviceToken(userID: String) async throws {
    guard let deviceToken = getDeviceToken() else {
      throw PushNotificationError.noDeviceToken
    }

    try await AppWriteService.shared.registerDeviceToken(deviceToken, userID: userID)
    print("✅ Device token registered to AppWrite for user: \(userID)")
  }

  // MARK: - Schedule Notification

  func requestPushSchedule(for product: Product, userID: String) async throws {
    try await AppWriteService.shared.scheduleNotification(
      productId: product.id.uuidString,
      productName: product.name,
      notificationDate: product.notificationDate,
      userID: userID
    )

    print("✅ Push notification scheduled for product: \(product.name) at \(product.notificationDate)")
  }

  func cancelPushSchedule(for product: Product) async throws {
    try await AppWriteService.shared.cancelScheduledNotification(productId: product.id.uuidString)
    print("✅ Push notification cancelled for product: \(product.name)")
  }
}

enum PushNotificationError: LocalizedError {
  case noDeviceToken
  case registrationFailed

  var errorDescription: String? {
    switch self {
    case .noDeviceToken:
      return "noDeviceToken"
    case .registrationFailed:
      return "registrationFailed"
    }
  }
}
