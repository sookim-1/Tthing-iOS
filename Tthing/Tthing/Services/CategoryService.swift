//
//  CategoryService.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import Appwrite
import AppwriteModels

class CategoryService {
  static let shared = CategoryService()

  private init() {}

  // MARK: - Category Operations

  func fetchAllCategories(userID: String) async throws -> [Category] {
      do {
          let userCategories = try await fetchUserCategories(userID: userID)

          return userCategories.sorted { $0.name < $1.name }
      } catch {
          return Category.defaultCategories
      }
  }

  func fetchUserCategories(userID: String) async throws -> [Category] {
    let rowList = try await AppWriteService.shared.listRow(
      tableId: AppConfiguration.categoriesCollectionID,
      queries: nil
    )

    var categories: [Category] = []

    for row in rowList.rows {
      if let category = Category.from(dictionary: row.data, rowId: row.id) {
        categories.append(category)
      }
    }

    return categories.sorted { $0.name < $1.name }
  }

  func createCategory(_ category: Category, userID: String) async throws -> Category {
    var categoryDict = category.toDictionary()
    categoryDict["isCustom"] = true
    categoryDict["createdBy"] = userID

    let row = try await AppWriteService.shared.createRow(
      tableId: AppConfiguration.categoriesCollectionID,
      data: categoryDict
    )

    guard let savedCategory = Category.from(dictionary: row.data, rowId: row.id) else {
      throw CategoryServiceError.failedToConvertCategory
    }

    return savedCategory
  }

  func deleteCategory(_ category: Category) async throws {
    guard category.isCustom else {
      throw CategoryServiceError.cannotDeleteDefaultCategory
    }

    guard let rowId = category.rowId else {
      throw CategoryServiceError.missingRowId
    }

    _ = try await AppWriteService.shared.deleteRow(
      tableId: AppConfiguration.categoriesCollectionID,
      rowId: rowId
    )
  }
}

enum CategoryServiceError: LocalizedError {
  case failedToConvertCategory
  case cannotDeleteDefaultCategory
  case missingRowId

  var errorDescription: String? {
    switch self {
    case .failedToConvertCategory:
      return "failedToConvertCategory"
    case .cannotDeleteDefaultCategory:
      return "cannotDeleteDefaultCategory"
    case .missingRowId:
      return "missingRowId"
    }
  }
}
