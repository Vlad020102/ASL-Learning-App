//
//  asl_mobile_appApp.swift
//  asl-mobile-app
//

import SwiftUI
import KeychainAccess
@main
struct asl_mobile_app: App {
    @StateObject private var authManager = AuthManager()

    init() {
        // Set up notifications when app launches
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
        }
    }
    
    private func setupNotifications() {
        // Request notification permissions
        NotificationService.shared.requestNotificationPermission { granted in
            if granted {
                // Schedule the daily reminder notification
                NotificationService.shared.scheduleReminderIfNeeded()
            } else {
                print("Notification permissions denied")
            }
        }
    }
}

struct RootView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var targetSign: String = "Hello"
    @State private var isCorrectSign: Bool = false
    
    // Track tab changes
    @State private var previousView: String = ""
    @State private var currentView: String = ""
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView()
                    .onAppear {
                        // When view changes, notify camera to clean up
                        if previousView == "CameraView" && currentView != "CameraView" {
                            cleanupCamera()
                        }
                        previousView = currentView
                        currentView = "ContentView"
                    }
            } else {
                HomeView()
                    .transition(.opacity)
                    .onAppear {
                        previousView = currentView
                        currentView = "HomeView"
                    }
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
        .onAppear {
            // If user logs in, update notification content
            if authManager.isAuthenticated {
                NotificationService.shared.scheduleReminderIfNeeded()
            }
        }
    }
    
    // Helper to post camera cleanup notification
    private func cleanupCamera() {
        print("🧨 Tab changed from Camera - posting cleanup notification")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cameraViewCleanup, object: nil)
        }
    }
}
