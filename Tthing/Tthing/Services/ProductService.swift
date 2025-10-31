//
//  ProductService.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import Appwrite
import AppwriteModels

class ProductService {
  static let shared = ProductService()

  private init() {}

  // MARK: - Product Operations

  func saveProduct(_ product: Product, userID: String) async throws -> Product {
    var productDict = product.toDictionary()
    productDict["userID"] = userID

    let row = try await AppWriteService.shared.createRow(
      tableId: AppConfiguration.productsCollectionID,
      data: productDict
    )

    guard let savedProduct = Product.from(dictionary: row.data, rowId: row.id) else {
      throw ProductServiceError.failedToConvertProduct
    }

    return savedProduct
  }

  func fetchProducts(userID: String) async throws -> [Product] {
      let queries = [
        Query.equal("userID", value: userID)
      ]
      
    let rowList = try await AppWriteService.shared.listRow(
      tableId: AppConfiguration.productsCollectionID,
      queries: queries
    )

    var products: [Product] = []

    for row in rowList.rows {
        if let product = Product.from(dictionary: row.data, rowId: row.id) {
        products.append(product)
      }
    }

    // Sort by startDate descending
    return products.sorted { $0.startDate > $1.startDate }
  }

  func fetchActiveProducts(userID: String) async throws -> [Product] {
    let queries = [
          Query.equal("userID", value: userID),
          Query.equal("isCompleted", value: false)
    ]

    let rowList = try await AppWriteService.shared.listRow(
      tableId: AppConfiguration.productsCollectionID,
      queries: queries
    )

    var products: [Product] = []

    for row in rowList.rows {
      if let product = Product.from(dictionary: row.data, rowId: row.id) {
        products.append(product)
      }
    }

    // Sort by startDate descending
    return products.sorted { $0.startDate > $1.startDate }
  }

  func updateProduct(_ product: Product, userID: String) async throws -> Product {
    guard let rowId = product.rowId else {
      throw ProductServiceError.missingRowId
    }

    var productDict = product.toDictionary()
    productDict["userID"] = userID
    productDict["updatedAt"] = ISO8601DateFormatter().string(from: Date())

    let row = try await AppWriteService.shared.updateRow(
      tableId: AppConfiguration.productsCollectionID,
      rowId: rowId,
      data: productDict
    )

    guard let updatedProduct = Product.from(dictionary: row.data, rowId: row.id) else {
      throw ProductServiceError.failedToConvertProduct
    }

    return updatedProduct
  }

  func deleteProduct(_ product: Product) async throws {
    guard let rowId = product.rowId else {
      throw ProductServiceError.missingRowId
    }

    if let fileId = product.photoURL {
      try? await AppWriteService.shared.deleteFile(fileId: fileId)
    }

    _ = try await AppWriteService.shared.deleteRow(
      tableId: AppConfiguration.productsCollectionID,
      rowId: rowId
    )
  }

  func completeProduct(_ product: Product, userID: String) async throws -> Product {
    guard let rowId = product.rowId else {
      throw ProductServiceError.missingRowId
    }

    var productDict = product.toDictionary()
    productDict["userID"] = userID
    productDict["isCompleted"] = true
    productDict["updatedAt"] = ISO8601DateFormatter().string(from: Date())

    let row = try await AppWriteService.shared.updateRow(
      tableId: AppConfiguration.productsCollectionID,
      rowId: rowId,
      data: productDict
    )

    guard let completedProduct = Product.from(dictionary: row.data, rowId: row.id) else {
      throw ProductServiceError.failedToConvertProduct
    }

    return completedProduct
  }
}

enum ProductServiceError: LocalizedError {
  case failedToConvertProduct
  case missingRowId

  var errorDescription: String? {
    switch self {
    case .failedToConvertProduct:
      return "failedToConvertProduct"
    case .missingRowId:
      return "missingRowId"
    }
  }
}
