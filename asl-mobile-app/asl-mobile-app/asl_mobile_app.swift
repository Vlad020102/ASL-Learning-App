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
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView()
                                        
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
        .onAppear {
            // If user logs in, update notification content
            if authManager.isAuthenticated {
                NotificationService.shared.updateNotificationContent()
            }
        }
    }
}
