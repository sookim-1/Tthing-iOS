//
//  Constants.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation

enum AppConfiguration {
    
  // AppWrite Set
  static let appWriteEndpoint = "https://nyc.cloud.appwrite.io/v1"
  static let appWriteProjectID = "6902ef4c002ad1b6c2ad"
  static let bundleID = "com.sookim.tthing"

  // AppWrite Database Set
  static let databaseID = "690440aa000e11cea0dd" // tthing-db
  static let productsCollectionID = "products"
  static let categoriesCollectionID = "categories"
  static let deviceTokensCollectionID = "device_tokens"
  static let notificationSchedulesCollectionID = "notification_schedules"

  // AppWrite Storage Set
  static let storageID = "690440d70011343b6079" // product-photos

  // Notification set
  static let defaultNotificationOffset = -7  // D-7
    
}

enum UIConstants {
  // 간격
  static let paddingSmall: CGFloat = 8
  static let paddingMedium: CGFloat = 16
  static let paddingLarge: CGFloat = 24

  // 코너 반경
  static let cornerRadiusSmall: CGFloat = 8
  static let cornerRadiusMedium: CGFloat = 12
  static let cornerRadiusLarge: CGFloat = 16

  // 이미지 크기
  static let thumbnailSize: CGFloat = 200
  static let cardImageSize: CGFloat = 120

  // 애니메이션
  static let animationDuration: Double = 0.3
}

enum ErrorMessages {
  static let networkError = "Network Connection Error"
  static let authError = "Auth Error"
  static let unknownError = "Unknown Error"
  static let invalidInput = "Invalid Input"
}
