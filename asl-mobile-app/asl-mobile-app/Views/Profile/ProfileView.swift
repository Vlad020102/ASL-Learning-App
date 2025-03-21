//
//  ProfileView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 19.03.2025.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    ProfileHeaderView()
                    
                    // Statistics
                    StatisticsView()
                    
                    // Achievements
                    AchievementsView()
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(AppColors.background)
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        VStack {
            HStack {
                
                    Spacer()
                    Text("Profile")
                        .font(.headline)
                    Spacer()
                    NavigationLink(destination: AccountSettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                    }
            
            }
            .padding()
            
            Divider()

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 70, height: 70)
                    
                    Text("R")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 25, y: 25)
                }
                
                Text("Kakashi Hatake")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("kakashi.hatake@example.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    Label("Joined March 2021", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label("0 Friends", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
            .padding(.bottom, 16)
        }
        .background(AppColors.accent3)
        .cornerRadius(10)
        .padding(.bottom, 16)
    }
        
}

struct StatisticsView: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Day streak stat
                StatCard(icon: "flame.fill", iconColor: .orange, value: "1", label: "Day streak")
                
                // Total XP stat
                StatCard(icon: "bolt.fill", iconColor: .yellow, value: "531", label: "Total XP")
            }
            
            HStack(spacing: 10) {
                // League stat
                ZStack(alignment: .topTrailing) {
                    StatCard(icon: "trophy.fill", iconColor: .yellow, value: "Gold", label: "League")
                        .overlay(
                            Text("WEEK 1")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .cornerRadius(4)
                                .offset(y: -12),
                            alignment: .top
                        )
                }
                
                // Top 3 finishes stat
                StatCard(icon: "rosette", iconColor: .gray, value: "0", label: "Top 3 finishes")
            }
        }
        .padding(.bottom, 16)
    }
}

struct StatCard: View {
    var icon: String
    var iconColor: Color
    var value: String
    var label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accent3)
        .cornerRadius(10)
    }
}

struct AchievementsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .foregroundColor(AppColors.secondary)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 4)
            
            // Wildfire achievement
            AchievementCard(
                title: "Wildfire",
                level: 1,
                progress: 1,
                total: 3,
                description: "Reach a 3 day streak",
                iconBackground: .red,
                iconSymbol: "flame.fill"
            )
            
            // Sage achievement
            AchievementCard(
                title: "Sage",
                level: 4,
                progress: 541,
                total: 1000,
                description: "Earn 1000 XP",
                iconBackground: .green,
                iconSymbol: "leaf.fill"
            )
            
            // Scholar achievement
            AchievementCard(
                title: "Scholar",
                level: 3,
                progress: 146,
                total: 175,
                description: "Learn 175 new words in a single course",
                iconBackground: .red,
                iconSymbol: "book.fill"
            )
            
            Button(action: {}) {
                Text("View all")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .padding(.top, 8)
        }
        .padding(.top, 8)
    }
}

struct AchievementCard: View {
    var title: String
    var level: Int
    var progress: Int
    var total: Int
    var description: String
    var iconBackground: Color
    var iconSymbol: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Achievement icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackground)
                    .frame(width: 56, height: 56)
                
                Image(systemName: iconSymbol)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("LEVEL \(level)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(4)
                    .offset(y: 16)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(progress)/\(total)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: geometry.size.width * CGFloat(progress) / CGFloat(total), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(AppColors.accent3)
        .cornerRadius(10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
