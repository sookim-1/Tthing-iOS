//
//  ProductCardView.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI

struct ProductCardView: View {
  let product: Product

  var body: some View {
    VStack(spacing: 12) {
      AppWriteImageView(
        fileId: product.photoURL,
        placeholderIcon: "photo",
        isPreview: true
      )
      .frame(height: 120)
      .frame(maxWidth: .infinity)
      .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium))

      VStack(alignment: .leading, spacing: 8) {
        Text(product.name)
          .font(.headline)
          .lineLimit(1)

        Text(product.category)
          .font(.caption)
          .foregroundColor(.secondary)

        HStack {
          Text(dDayText)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(statusColor)

          Spacer()

          Circle()
            .fill(statusColor)
            .frame(width: 8, height: 8)
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 12)
    }
    .background(Color(.systemBackground))
    .cornerRadius(UIConstants.cornerRadiusMedium)
    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
  }

  private var dDayText: String {
    let days = product.daysRemaining
    if days < 0 {
      return "D+\(abs(days))"
    } else if days == 0 {
      return "D-Day"
    } else {
      return "D-\(days)"
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
