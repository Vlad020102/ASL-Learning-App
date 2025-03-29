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
            AlphabetExerciseView()
                
        }
    }
}

struct RootView: View {
    @State private var targetSign: String = "Hello"
    @State private var isCorrectSign: Bool = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                CameraView(targetSign: $targetSign, isCorrectSign: $isCorrectSign).environmentObject(authManager)
                    .transition(.opacity)
            } else {
                HomePage()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
    }
}

struct Main_preview: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(AuthManager())
    }
}

