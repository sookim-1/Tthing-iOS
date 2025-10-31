//
//  CategoryPickerview.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI

@MainActor
class CategoryPickerViewModel: ObservableObject {
  @Published var categories: [Category] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  func loadCategories(userID: String) async {
    isLoading = true
    errorMessage = nil

    do {
      categories = try await CategoryService.shared.fetchAllCategories(userID: userID)
    } catch {
      errorMessage = "Fail Load Category: \(error.localizedDescription)"
      print("Load categories error: \(error)")
      categories = Category.defaultCategories
    }

    isLoading = false
  }
}

struct CategoryPickerView: View {
  @StateObject private var viewModel = CategoryPickerViewModel()
  @EnvironmentObject var authViewModel: AuthViewModel
  @Binding var selectedCategory: Category?
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading {
          ProgressView("Loading...")
        } else {
          List {
            Section("Category") {
              ForEach(viewModel.categories) { category in
                Button {
                  selectedCategory = category
                  dismiss()
                } label: {
                  HStack(spacing: 16) {
                    Text(category.iconName)
                      .font(.title2)
                      .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                      Text(category.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                      Text("Recommend: \(category.recommendedLifespan) day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    if selectedCategory?.id == category.id {
                      Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                    }
                  }
                }
              }
            }
          }
        }
      }
      .navigationTitle("Category")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      .onAppear {
        Task {
          if let userID = authViewModel.currentUser?.id {
            await viewModel.loadCategories(userID: userID)
          } else {
            viewModel.categories = Category.defaultCategories
          }
        }
      }
      .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
        Button("Done") {
          viewModel.errorMessage = nil
        }
      } message: {
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
        }
      }
    }
  }
}
