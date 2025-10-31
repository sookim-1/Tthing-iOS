//
//  AddProductView.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
  @StateObject private var viewModel = ProductDetailViewModel()
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  @State private var showCategoryPicker = false

  var body: some View {
    NavigationStack {
      Form(content: {
        Section("Basic Info") {
          TextField("ProductName", text: $viewModel.name)

          Button {
            showCategoryPicker = true
          } label: {
            HStack {
              Text("Category")
                .foregroundColor(.primary)
              Spacer()
              if let category = viewModel.selectedCategory {
                Text("\(category.iconName) \(category.name)")
                  .foregroundColor(.secondary)
              } else {
                Text("Select")
                  .foregroundColor(.blue)
              }
            }
          }

          DatePicker(
            "Start Date",
            selection: $viewModel.startDate,
            displayedComponents: .date
          )
        }

        Section {
          HStack {
            Text("Recommend Date")
            Spacer()
            TextField("Day", value: $viewModel.recommendedLifespan, format: .number)
              .keyboardType(.numberPad)
              .multilineTextAlignment(.trailing)
              .frame(width: 80)
            Text("Day")
          }
        } header: {
          Text("Change Date")
        } footer: {
          Text("Change Date: \(viewModel.startDate.addingTimeInterval(TimeInterval(viewModel.recommendedLifespan * 24 * 60 * 60)).formatted(date: .long, time: .omitted))")
        }

        Section("Noti Offset") {
          Picker("Noti Offset", selection: $viewModel.notificationOffset) {
            Text("Today").tag(0)
            Text("D-1").tag(-1)
            Text("D-3").tag(-3)
            Text("D-7").tag(-7)
            Text("D-14").tag(-14)
          }
        }

        Section("Picture (Option)") {
          PhotosPicker(
            selection: $viewModel.selectedPhotoItem,
            matching: .images
          ) {
            HStack {
              if let photoData = viewModel.photoData,
                 let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 60, height: 60)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              } else {
                Image(systemName: "photo.badge.plus")
                  .font(.largeTitle)
                  .foregroundColor(.gray)
                  .frame(width: 60, height: 60)
              }

              Text("Select")
                .foregroundColor(.blue)
            }
          }
          .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task {
              await viewModel.loadPhotoData()
            }
          }
        }
      })
      .navigationTitle("Add Product")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Finish") {
            Task {
              do {
                guard let userID = authViewModel.currentUser?.id else { return }
                try await viewModel.saveProduct(userID: userID)
                dismiss()
              } catch {
                print("Save error: \(error)")
              }
            }
          }
          .disabled(viewModel.name.isEmpty || viewModel.category.isEmpty)
        }
      }
      .sheet(isPresented: $showCategoryPicker) {
        CategoryPickerView(selectedCategory: $viewModel.selectedCategory)
          .onDisappear {
            if let category = viewModel.selectedCategory {
              viewModel.selectCategory(category)
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
