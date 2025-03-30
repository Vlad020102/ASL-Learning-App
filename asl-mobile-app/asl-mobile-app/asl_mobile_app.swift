//
//  asl_mobile_appApp.swift
//  asl-mobile-app
//

import SwiftUI
import KeychainAccess
@main
struct asl_mobile_app: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
        }
    }
}

struct RootView: View {
    @StateObject private var authManager = AuthManager.shared

    @State private var targetSign: String = "Hello"
    @State private var isCorrectSign: Bool = false
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value:  authManager.isAuthenticated)
    }
}
