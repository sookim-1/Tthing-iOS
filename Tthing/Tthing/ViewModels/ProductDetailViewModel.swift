//
//  ProductDetailViewModel.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI
import PhotosUI

@MainActor
class ProductDetailViewModel: ObservableObject {
  @Published var product: Product?
  @Published var name = ""
  @Published var category = ""
  @Published var selectedCategory: Category?
  @Published var startDate = Date()
  @Published var recommendedLifespan = 90
  @Published var notificationOffset = -7
  @Published var selectedPhotoItem: PhotosPickerItem?
  @Published var photoData: Data?
  @Published var errorMessage: String?

  var isEditing: Bool {
    product != nil
  }

  func loadProduct(_ product: Product) {
    self.product = product
    name = product.name
    category = product.category
    startDate = product.startDate
    recommendedLifespan = product.recommendedLifespan
    notificationOffset = product.notificationOffset
  }

  func selectCategory(_ category: Category) {
    selectedCategory = category
    self.category = category.name
    recommendedLifespan = category.recommendedLifespan
  }

  func saveProduct(userID: String) async throws {
    guard !name.isEmpty, !category.isEmpty else {
      throw ProductDetailError.invalidInput
    }

    var uploadedFileId: String?
    if let photoData = photoData {
      if let existingProduct = product,
         let existingFileId = existingProduct.photoURL {
        try? await AppWriteService.shared.deleteFile(fileId: existingFileId)
      }

      let fileName = "\(UUID().uuidString).jpg"
      let uploadedFile = try await AppWriteService.shared.uploadFile(
        fileData: photoData,
        fileName: fileName,
        mimeType: "image/jpeg"
      )

      uploadedFileId = uploadedFile.id
    }

    if let existingProduct = product {
      let updatedProduct = Product(
        id: existingProduct.id,
        rowId: existingProduct.rowId,
        name: name,
        category: category,
        startDate: startDate,
        recommendedLifespan: recommendedLifespan,
        photoURL: uploadedFileId ?? existingProduct.photoURL,
        notificationOffset: notificationOffset,
        isCompleted: existingProduct.isCompleted,
        createdAt: existingProduct.createdAt,
        updatedAt: Date(),
        userID: userID
      )

      let savedProduct = try await ProductService.shared.updateProduct(updatedProduct, userID: userID)

      try? await PushNotificationService.shared.requestPushSchedule(for: savedProduct, userID: userID)
    } else {
      let newProduct = Product(
        name: name,
        category: category,
        startDate: startDate,
        recommendedLifespan: recommendedLifespan,
        photoURL: uploadedFileId,
        notificationOffset: notificationOffset,
        userID: userID
      )

      let savedProduct = try await ProductService.shared.saveProduct(newProduct, userID: userID)

      try? await PushNotificationService.shared.requestPushSchedule(for: savedProduct, userID: userID)
    }
  }

  func loadPhotoData() async {
    guard let photoItem = selectedPhotoItem else { return }

    do {
      if let data = try await photoItem.loadTransferable(type: Data.self) {
        photoData = data
      }
    } catch {
      errorMessage = "Fail Load Picture"
    }
  }
}

enum ProductDetailError: LocalizedError {
  case invalidInput

  var errorDescription: String? {
    switch self {
    case .invalidInput:
      return "Invalid Input"
    }
  }
}
