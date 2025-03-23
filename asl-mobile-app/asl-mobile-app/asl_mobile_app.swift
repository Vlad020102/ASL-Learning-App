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
    @State private var targetSign: String = "Hello"
    @State private var isCorrectSign: Bool = false
    @EnvironmentObject var authManager: AuthManager

    @StateObject private var authManager = AuthManager.shared
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                CameraView(targetSign: $targetSign, isCorrectSign: $isCorrectSign).environmentObject(authManager)
                    .transition(.opacity)
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value:  authManager.isAuthenticated)
    }
}

