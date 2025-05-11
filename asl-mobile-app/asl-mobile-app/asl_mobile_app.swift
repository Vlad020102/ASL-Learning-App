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
    
    @State private var previousView: String = ""
    @State private var currentView: String = ""
    
    @State private var showReferralAnimation: Bool = false
    @State private var referralAnimationCompleted: Bool = false
    
    var body: some View {
        ZStack {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .onAppear {
                            if previousView == "CameraView" && currentView != "CameraView" {
                                cleanupCamera()
                            }
                            previousView = currentView
                            currentView = "ContentView"
                            print(referralAnimationCompleted)
                            if AuthManager.shared.isReferred && !referralAnimationCompleted {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showReferralAnimation = true
                                }
                            }
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
                if authManager.isAuthenticated {
                    NotificationService.shared.scheduleReminderIfNeeded()
                }
            }
            
            if showReferralAnimation {
                ReferralSuccessView(showAnimation: $showReferralAnimation) {
                    referralAnimationCompleted = true
                }
                .transition(.opacity)
                .zIndex(10)
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
