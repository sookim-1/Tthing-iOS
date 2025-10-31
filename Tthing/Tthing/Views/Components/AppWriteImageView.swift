//
//  AppWriteImageView.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI

struct AppWriteImageView: View {
  let fileId: String?
  let placeholderIcon: String
    let isPreview: Bool

  @State private var imageData: Data?
  @State private var isLoading = false
  @State private var loadError = false

  init(
    fileId: String?,
    placeholderIcon: String = "photo",
    isPreview: Bool = false
  ) {
    self.fileId = fileId
    self.placeholderIcon = placeholderIcon
      self.isPreview = isPreview
  }

  var body: some View {
    Group {
      if let imageData = imageData,
         let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else if isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color(.systemGray6))
      } else {
        placeholderView
      }
    }
    .task {
      await loadImage()
    }
  }

  private var placeholderView: some View {
    Image(systemName: placeholderIcon)
      .font(.largeTitle)
      .foregroundColor(.gray)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.systemGray6))
  }

  private func loadImage() async {
    guard let fileId = fileId else { return }
    guard imageData == nil else { return } 

    isLoading = true
    loadError = false

    do {
        if isPreview {
            // Upgrade High Plan
            // let data = try await AppWriteService.shared.getPreviewFileData(fileId: fileId)
            let data = try await AppWriteService.shared.getFileData(fileId: fileId)
            imageData = data
        } else {
            let data = try await AppWriteService.shared.getFileData(fileId: fileId)
            imageData = data
        }
    } catch {
      print("Failed to load image: \(error.localizedDescription)")
      loadError = true
    }

    isLoading = false
  }
}
