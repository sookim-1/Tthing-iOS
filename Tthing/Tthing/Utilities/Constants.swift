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
  static let cornerRadiusMedium: CGFloat = 12
}

enum ErrorMessages {
  static let networkError = "Network Connection Error"
  static let authError = "Auth Error"
  static let unknownError = "Unknown Error"
  static let invalidInput = "Invalid Input"
}
