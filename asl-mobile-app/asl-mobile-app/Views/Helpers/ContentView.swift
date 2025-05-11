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
           ProfileView()
               .tabItem {
                   Image(systemName: "person.fill")
                   Text("Profile")
               }
               .tag(0)
            
            // Camera Tab
            SimpleCameraView(targetSign: $targetSign, isCorrectSign: $isCorrectSign)
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .tag(1)
            
            // Lessons Tab
            QuizCatalogueView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("quizzes")
                }
                .tag(2)
            WikiView()
                .tabItem{
                    Image(systemName: "book.pages")
                    Text("Wiki")
                }
                .tag(3)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(named: "accent3")

            // Unselected: gray
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

            // Selected: accent1
            let accent1Color = UIColor(named: "accent1") ?? .systemYellow
            appearance.stackedLayoutAppearance.selected.iconColor = accent1Color
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accent1Color]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
