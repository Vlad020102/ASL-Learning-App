//
//  BadgeDetailView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone"
//

import SwiftUI

struct BadgeDetailView: View {
    let badge: Badge
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Badge Icon and Name
                VStack(spacing: 10) {
                    Image(systemName: badge.icon)
                        .font(.system(size: 80))
                        .foregroundColor(getBadgeColor(rarity: badge.rarity))
                        .padding()
                        .background(getBadgeColor(rarity: badge.rarity).opacity(0.2))
                        .clipShape(Circle())
                    
                    Text(badge.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Badge Details
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(title: "Description", value: badge.description)
                    DetailRow(title: "Type", value: badge.type)
                    DetailRow(title: "Rarity", value: badge.rarity)
                    DetailRow(title: "Status", value: badge.status)
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Progress")
                            .font(.headline)
                            .foregroundColor(AppColors.secondary)
                        
                        Text("\(badge.progress) / 100")
                            .font(.subheadline)
                        
                        ProgressBar(progress: Double(badge.progress) / 100.00)
                            .frame(height: 10)
                            .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(AppColors.accent3)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Badge Details")
        .background(AppColors.background)
    }
    
    private func getBadgeColor(rarity: String) -> Color {
        switch rarity.lowercased() {
        case "common":
            return .green
        case "uncommon":
            return .blue
        case "rare":
            return .purple
        case "epic":
            return .orange
        case "legendary":
            return .red
        default:
            return .gray
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.secondary)
            Text(value)
                .font(.subheadline)
        }
    }
}

struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(AppColors.primary)
            }
            .cornerRadius(45)
        }
    }
}

struct BadgeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BadgeDetailView(badge: Badge(id: 1, name: "Learning Master", description: "Complete 100 lessons", icon: "graduationcap.fill", type: "Achievement", rarity: "Rare", progress: 75, status: "In Progress", target: 100))
        }
    }
}
