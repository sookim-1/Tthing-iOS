//
//  ProductDetailSheet.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI

struct ProductDetailSheet: View {
  let product: Product
  @ObservedObject var viewModel: ProductListViewModel
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  @State private var showCompleteConfirmation = false
  @State private var showDeleteConfirmation = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          AppWriteImageView(
            fileId: product.photoURL,
            placeholderIcon: "photo"
          )
          .frame(height: 250)
          .frame(maxWidth: .infinity)
          .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium))

          VStack(alignment: .leading, spacing: 16) {
            Text(product.name)
              .font(.title)
              .fontWeight(.bold)

            HStack {
              Label(product.category, systemImage: "tag")
                .font(.subheadline)
                .foregroundColor(.secondary)

              Spacer()

              Text(statusText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor)
                .cornerRadius(12)
            }

            Divider()

            VStack(spacing: 12) {
              InfoRow(
                title: "Start Date",
                value: product.startDate.formatted(date: .long, time: .omitted)
              )

              InfoRow(
                title: "Replacement Date",
                value: product.replacementDate.formatted(date: .long, time: .omitted)
              )

              InfoRow(
                title: "Day Remaining",
                value: "\(product.daysRemaining) day"
              )

              InfoRow(
                title: "RecommendedLifespan",
                value: "\(product.recommendedLifespan) day"
              )
            }

            Divider()

            VStack(spacing: 12) {
              Button {
                showCompleteConfirmation = true
              } label: {
                Label("Done", systemImage: "checkmark.circle.fill")
                  .font(.headline)
                  .foregroundColor(.white)
                  .frame(maxWidth: .infinity)
                  .frame(height: 50)
                  .background(Color.blue)
                  .cornerRadius(UIConstants.cornerRadiusMedium)
              }

              Button(role: .destructive) {
                showDeleteConfirmation = true
              } label: {
                Label("Delete", systemImage: "trash")
                  .font(.headline)
                  .foregroundColor(.red)
                  .frame(maxWidth: .infinity)
                  .frame(height: 50)
                  .background(Color.red.opacity(0.1))
                  .cornerRadius(UIConstants.cornerRadiusMedium)
              }
            }
          }
          .padding()
        }
        .padding()
      }
      .navigationTitle("Detail")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      .confirmationDialog(
        "Done",
        isPresented: $showCompleteConfirmation,
        titleVisibility: .visible
      ) {
        Button("Done") {
          Task {
            guard let userID = authViewModel.currentUser?.id else { return }
            await viewModel.completeProduct(product, userID: userID)
            await viewModel.loadProducts(userID: userID)
            dismiss()
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("Would you \(product.name) Done?")
      }
      .confirmationDialog(
        "Delete Confirm",
        isPresented: $showDeleteConfirmation,
        titleVisibility: .visible
      ) {
        Button("Delete", role: .destructive) {
          Task {
            await viewModel.deleteProduct(product)
            if let userID = authViewModel.currentUser?.id {
              await viewModel.loadProducts(userID: userID)
            }
            dismiss()
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("Would you \(product.name) Done?")
      }
    }
  }

  private var statusText: String {
    switch product.status {
    case .overdue:
      return "Over due"
    case .today:
      return "Today"
    case .soon:
      return "Soon"
    case .normal:
      return "Normal"
    }
  }

  private var statusColor: Color {
    switch product.status {
    case .overdue:
      return .red
    case .today:
      return .orange
    case .soon:
      return .yellow
    case .normal:
      return .green
    }
  }
}

struct InfoRow: View {
  let title: String
  let value: String

  var body: some View {
    HStack {
      Text(title)
        .font(.subheadline)
        .foregroundColor(.secondary)

      Spacer()

      Text(value)
        .font(.subheadline)
        .fontWeight(.medium)
    }
  }
}

