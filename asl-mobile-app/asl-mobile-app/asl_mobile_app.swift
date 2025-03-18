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
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                CameraView()
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

