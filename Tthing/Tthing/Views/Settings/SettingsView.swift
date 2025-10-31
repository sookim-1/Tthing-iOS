//
//  SettingsView.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import SwiftUI


struct SettingsView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @Environment(\.dismiss) var dismiss

  @State private var showLogoutConfirmation = false

  var body: some View {
    NavigationStack {
      List {
        Section {
          if let user = authViewModel.currentUser {
            HStack {
              Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)

              VStack(alignment: .leading, spacing: 4) {
                Text(user.name ?? "User")
                  .font(.headline)

                if let email = user.email {
                  Text(email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }

              Spacer()
            }
          }
        }

        Section("App Info") {
          HStack {
            Text("Version")
            Spacer()
            Text("1.0.0")
              .foregroundColor(.secondary)
          }

          Link(destination: URL(string: "https://github.com")!) {
            HStack {
              Text("Private")
              Spacer()
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          Link(destination: URL(string: "https://github.com")!) {
            HStack {
              Text("Service Terms")
              Spacer()
              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }

        Section("Account") {
          Button(role: .destructive) {
            showLogoutConfirmation = true
          } label: {
            Text("Logout")
          }
        }
      }
      .navigationTitle("Setting")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Close") {
            dismiss()
          }
        }
      }
      .confirmationDialog(
        "Logout",
        isPresented: $showLogoutConfirmation,
        titleVisibility: .visible
      ) {
        Button("Logout", role: .destructive) {
          Task {
            await authViewModel.logout()
            dismiss()
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("Would you Logout?")
      }
    }
  }
}
