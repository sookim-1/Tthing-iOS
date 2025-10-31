//
//  Product.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import JSONCodable

struct Product: Identifiable, Codable {
  var id: UUID
  var rowId: String?
  var name: String
  var category: String
  var startDate: Date
  var recommendedLifespan: Int
  var photoURL: String?
  var notificationOffset: Int
  var isCompleted: Bool
  var createdAt: Date
  var updatedAt: Date
  var userID: String?

  var replacementDate: Date {
    Calendar.current.date(byAdding: .day, value: recommendedLifespan, to: startDate) ?? startDate
  }

  var notificationDate: Date {
    Calendar.current.date(byAdding: .day, value: notificationOffset, to: replacementDate) ?? replacementDate
  }

  var daysRemaining: Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let replacement = calendar.startOfDay(for: replacementDate)
    let components = calendar.dateComponents([.day], from: today, to: replacement)
    return components.day ?? 0
  }

  var isOverdue: Bool {
    daysRemaining < 0
  }

  var status: ProductStatus {
    let days = daysRemaining
    if days < 0 {
      return .overdue
    } else if days == 0 {
      return .today
    } else if days <= 7 {
      return .soon
    } else {
      return .normal
    }
  }

  init(
    id: UUID = UUID(),
    rowId: String? = nil,
    name: String,
    category: String,
    startDate: Date,
    recommendedLifespan: Int,
    photoURL: String? = nil,
    notificationOffset: Int = -7,
    isCompleted: Bool = false,
    createdAt: Date = Date(),
    updatedAt: Date = Date(),
    userID: String? = nil
  ) {
    self.id = id
    self.rowId = rowId
    self.name = name
    self.category = category
    self.startDate = startDate
    self.recommendedLifespan = recommendedLifespan
    self.photoURL = photoURL
    self.notificationOffset = notificationOffset
    self.isCompleted = isCompleted
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.userID = userID
  }
}

enum ProductStatus {
  case overdue
  case today
  case soon
  case normal
}

// MARK: - Codable for AppWrite

extension Product {
  func toDictionary() -> [String: Any] {
    [
      "id": id.uuidString,
      "name": name,
      "category": category,
      "startDate": ISO8601DateFormatter().string(from: startDate),
      "recommendedLifespan": recommendedLifespan,
      "photoURL": photoURL as Any,
      "notificationOffset": notificationOffset,
      "isCompleted": isCompleted,
      "createdAt": ISO8601DateFormatter().string(from: createdAt),
      "updatedAt": ISO8601DateFormatter().string(from: updatedAt),
      "userID": userID as Any
    ]
  }

  static func from(dictionary: [String: AnyCodable], rowId: String? = nil) -> Product? {
    guard
        let name = dictionary["name"]?.value as? String,
        let category = dictionary["category"]?.value as? String,
        let recommendedLifespan = dictionary["recommendedLifespan"]?.value as? Int
    else {
      return nil
    }

      let startDateString = dictionary["startDate"]?.value as? String
      let startDate = startDateString.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()

      let photoURL = dictionary["photoURL"]?.value as? String
      let notificationOffset = dictionary["notificationOffset"]?.value as? Int ?? -7
      let isCompleted = dictionary["isCompleted"]?.value as? Bool ?? false

      let createdAtString = dictionary["createdAt"]?.value as? String
    let createdAt = createdAtString.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()

      let updatedAtString = dictionary["updatedAt"]?.value as? String
    let updatedAt = updatedAtString.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()

      let userID = dictionary["userID"]?.value as? String

    return Product(
      rowId: rowId,
      name: name,
      category: category,
      startDate: startDate,
      recommendedLifespan: recommendedLifespan,
      photoURL: photoURL,
      notificationOffset: notificationOffset,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userID: userID
    )
  }
}
