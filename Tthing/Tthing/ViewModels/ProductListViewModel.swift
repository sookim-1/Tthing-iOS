//
//  ProductListViewModel.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import SwiftUI

@MainActor
class ProductListViewModel: ObservableObject {
  @Published var products: [Product] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  func loadProducts(userID: String) async {
    isLoading = true

    do {
      products = try await ProductService.shared.fetchActiveProducts(userID: userID)
    } catch {
      errorMessage = "Fail Load Product"
      print("Load products error: \(error)")
    }

    isLoading = false
  }

  func deleteProduct(_ product: Product) async {
    do {
      try await ProductService.shared.deleteProduct(product)

      // 푸시 알림 취소
      try? await PushNotificationService.shared.cancelPushSchedule(for: product)
    } catch {
      errorMessage = "Fail delete Product"
    }
  }

  func completeProduct(_ product: Product, userID: String) async {
    do {
      _ = try await ProductService.shared.completeProduct(product, userID: userID)

      // 푸시 알림 취소
      try? await PushNotificationService.shared.cancelPushSchedule(for: product)
    } catch {
      errorMessage = "Fail Complete Product"
    }
  }

}
