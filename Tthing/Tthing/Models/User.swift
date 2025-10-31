//
//  User.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import Appwrite
import JSONCodable

struct User: Identifiable, Codable {
  var id: String  // AppWrite User ID
  var name: String?
  var email: String?
  var createdAt: Date
  var updatedAt: Date

  init(
    id: String,
    name: String? = nil,
    email: String? = nil,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

// MARK: - AppWrite User Conversion

extension User {
  static func from(appwriteUser: AppwriteModels.User<[String: AnyCodable]>) -> User {
    let createdDate = ISO8601DateFormatter().date(from: appwriteUser.registration ?? "") ?? Date()

    return User(
      id: appwriteUser.id,
      name: appwriteUser.name,
      email: appwriteUser.email,
      createdAt: createdDate,
      updatedAt: createdDate
    )
  }
}
