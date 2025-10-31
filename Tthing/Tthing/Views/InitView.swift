//
//  ContentView.swift
//  Tthing
//
//  Created by sookim on 10/31/25.
//

import SwiftUI

struct InitView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
      Group {
        if authViewModel.isAuthenticated {
          HomeView()
        } else {
          AuthView()
        }
      }
      .onAppear {
        Task {
          await authViewModel.checkAuthStatus()
        }
      }
    }
  }

