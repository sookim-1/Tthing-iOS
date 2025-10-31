//
//  AuthViewModel.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class AuthViewModel: ObservableObject {
  @Published var isAuthenticated = false
  @Published var currentUser: User?
  @Published var isLoading = false
  @Published var errorMessage: String?

  func checkAuthStatus() async {
    isLoading = true

    do {
      let appwriteUser = try await AppWriteService.shared.getCurrentUser()
      currentUser = User.from(appwriteUser: appwriteUser)
      isAuthenticated = true

      await setupPushNotifications()
    } catch {
      print("Not authenticated: \(error)")
      isAuthenticated = false
    }

    isLoading = false
  }

  func login(email: String, password: String) async {
    isLoading = true
    errorMessage = nil

    do {
      _ = try await AppWriteService.shared.login(email: email, password: password)
      let appwriteUser = try await AppWriteService.shared.getCurrentUser()
      currentUser = User.from(appwriteUser: appwriteUser)
      isAuthenticated = true

      await setupPushNotifications()
    } catch {
      errorMessage = "Login Error"
      print("Login error: \(error)")
    }

    isLoading = false
  }

  func register(email: String, password: String) async {
    isLoading = true
    errorMessage = nil

    do {
      _ = try await AppWriteService.shared.register(email: email, password: password)
      await login(email: email, password: password)
    } catch {
      errorMessage = "Register Error"
      print("Register error: \(error)")
    }

    isLoading = false
  }

  func logout() async {
    isLoading = true

    do {
      try await AppWriteService.shared.logout()
      currentUser = nil
      isAuthenticated = false
    } catch {
      errorMessage = "Logout Error"
      print("Logout error: \(error)")
    }

    isLoading = false
  }

  // MARK: - Push Notification Setup

  private func setupPushNotifications() async {
    guard let userID = currentUser?.id else { return }

      do {
          try await PushNotificationService.shared.registerDeviceToken(userID: userID)
          _ = try await AppWriteService.shared.createTarget()
          print("✅ Device token registered to AppWrite")
      } catch {
          print("❌ Failed to setup push notifications: \(error.localizedDescription)")
    }
  }
}
