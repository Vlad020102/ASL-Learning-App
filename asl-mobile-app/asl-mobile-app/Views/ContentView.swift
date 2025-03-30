//
//  ContentView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 19.03.2025.
//
import SwiftUI

struct ContentView: View {
    // Initially selected tab
    @State private var selectedTab = 0
    
    @State private var targetSign: String = "Hello"
    @State private var isCorrectSign: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(0)
            
            // Camera Tab
            CameraView(targetSign: $targetSign, isCorrectSign: $isCorrectSign)
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .tag(1)
            
            // Lessons Tab
            QuizCatalogueView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Lessons")
                }
                .tag(2)
        }
        // This ensures the tab bar is always visible
        .onAppear() {
            // Set the default tab bar appearance to make it persistent
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
