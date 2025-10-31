//
//  TthingApp.swift
//  Tthing
//
//  Created by sookim on 10/31/25.
//

import SwiftUI

@main
struct TthingApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            InitView()
              .environmentObject(authViewModel)
        }
    }
}
