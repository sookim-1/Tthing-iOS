//
//  EmptyStateView.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI

struct EmptyStateView: View {
  @Binding var showAddProduct: Bool

  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "tray")
        .font(.system(size: 80))
        .foregroundColor(.gray)

      VStack(spacing: 12) {
        Text("Not Register Product")
          .font(.title2)
          .fontWeight(.semibold)

        Text("First Register Product")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }

      Button {
        showAddProduct = true
      } label: {
        Label("Add Product", systemImage: "plus.circle.fill")
          .font(.headline)
          .foregroundColor(.white)
          .padding(.horizontal, 32)
          .padding(.vertical, 16)
          .background(Color.blue)
          .cornerRadius(UIConstants.cornerRadiusMedium)
      }
    }
    .padding()
  }
}
