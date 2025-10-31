//
//  Category.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import JSONCodable

struct Category: Identifiable, Codable, Hashable {
  var id: UUID
  var rowId: String?
  var name: String
  var iconName: String
  var recommendedLifespan: Int
  var isCustom: Bool
  var createdBy: String?

  init(
    id: UUID = UUID(),
    rowId: String? = nil,
    name: String,
    iconName: String,
    recommendedLifespan: Int,
    isCustom: Bool = false,
    createdBy: String? = nil
  ) {
    self.id = id
    self.rowId = rowId
    self.name = name
    self.iconName = iconName
    self.recommendedLifespan = recommendedLifespan
    self.isCustom = isCustom
    self.createdBy = createdBy
  }
}

// MARK: - Default Categories

extension Category {
  static let defaultCategories: [Category] = [
    Category(name: "Brush", iconName: "🪥", recommendedLifespan: 90)
  ]
}

// MARK: - AppWrite Conversion

extension Category {
  func toDictionary() -> [String: Any] {
    [
      "id": id.uuidString,
      "name": name,
      "iconName": iconName,
      "recommendedLifespan": recommendedLifespan,
      "isCustom": isCustom,
      "createdBy": createdBy as Any
    ]
  }

  static func from(dictionary: [String: AnyCodable], rowId: String? = nil) -> Category? {
    guard
        let name = dictionary["name"]?.value as? String,
        let iconName = dictionary["iconName"]?.value as? String,
        let recommendedLifespan = dictionary["recommendedLifespan"]?.value as? Int
    else {
      return nil
    }

      let isCustom = dictionary["isCustom"]?.value as? Bool ?? false
      let createdBy = dictionary["createdBy"]?.value as? String

    return Category(
      rowId: rowId,
      name: name,
      iconName: iconName,
      recommendedLifespan: recommendedLifespan,
      isCustom: isCustom,
      createdBy: createdBy
    )
  }
}
