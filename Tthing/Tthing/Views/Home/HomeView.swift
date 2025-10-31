//
//  HomeView.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = ProductListViewModel()
  @EnvironmentObject var authViewModel: AuthViewModel

  @State private var showAddProduct = false
  @State private var showSettings = false
  @State private var selectedProduct: Product?
  @State private var showReAddConfirmation = false
  @State private var completedProductCategory: String?

  var body: some View {
    NavigationStack {
      ZStack {
        if viewModel.products.isEmpty {
          EmptyStateView(showAddProduct: $showAddProduct)
        } else {
          ScrollView {
            LazyVGrid(
              columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
              ],
              spacing: 16
            ) {
              ForEach(viewModel.products) { product in
                ProductCardView(product: product)
                  .onTapGesture {
                    selectedProduct = product
                  }
                  .contextMenu {
                    Button(role: .destructive) {
                      Task {
                        await deleteProduct(product)
                      }
                    } label: {
                      Label("Delete", systemImage: "trash")
                    }

                    Button {
                      Task {
                        await completeProduct(product)
                      }
                    } label: {
                      Label("Finish", systemImage: "checkmark.circle")
                    }
                  }
              }
            }
            .padding()
          }
        }
      }
      .navigationTitle("🔔 TThing")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showSettings = true
          } label: {
            Image(systemName: "gearshape")
          }
        }
      }
      .overlay(alignment: .bottomTrailing) {
          if !viewModel.products.isEmpty {
              Button {
                  showAddProduct = true
              } label: {
                  Image(systemName: "plus")
                      .font(.title2)
                      .fontWeight(.semibold)
                      .foregroundColor(.white)
                      .frame(width: 56, height: 56)
                      .background(Color.blue)
                      .clipShape(Circle())
                      .shadow(radius: 4)
              }
              .padding(24)
          }
      }
      .sheet(isPresented: $showAddProduct) {
        AddProductView()
          .onDisappear {
            Task {
              if let userID = authViewModel.currentUser?.id {
                await viewModel.loadProducts(userID: userID)
              }
            }
          }
      }
      .sheet(item: $selectedProduct) { product in
        ProductDetailSheet(product: product, viewModel: viewModel)
      }
      .sheet(isPresented: $showSettings) {
        SettingsView()
      }
      .alert("Same product Registered?", isPresented: $showReAddConfirmation) {
        Button("Register") {
          showAddProduct = true
        }
        Button("Cancel", role: .cancel) {
          completedProductCategory = nil
        }
      } message: {
        if let category = completedProductCategory {
          Text("\(category) Product")
        }
      }
      .onAppear {
        Task {
          if let userID = authViewModel.currentUser?.id {
            await viewModel.loadProducts(userID: userID)
          }
        }
      }
    }
  }

  private func deleteProduct(_ product: Product) async {
    await viewModel.deleteProduct(product)

    if let userID = authViewModel.currentUser?.id {
      await viewModel.loadProducts(userID: userID)
    }
  }

  private func completeProduct(_ product: Product) async {
    guard let userID = authViewModel.currentUser?.id else { return }

    await viewModel.completeProduct(product, userID: userID)
    await viewModel.loadProducts(userID: userID)

    completedProductCategory = product.category
    showReAddConfirmation = true
  }
}
