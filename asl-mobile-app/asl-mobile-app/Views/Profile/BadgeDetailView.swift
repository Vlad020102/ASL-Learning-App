//
//  BadgeDetailView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone"
//

import SwiftUI

struct BadgeDetailView: View {
    let badge: Badge
    
    var rarityColor: Color {
        switch badge.rarity {
        case "Bronze": return .bronze
        case "Silver": return .silver
        case "Gold": return .gold
        default: return .gray
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Badge Icon and Name
                VStack(spacing: 10) {
                    Image(systemName: badge.icon)
                        .font(.system(size: 80))
                        .foregroundColor(rarityColor)
                        .padding()
                        .background(rarityColor.opacity(0.2))
                        .clipShape(Circle())
                    
                    Text(badge.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(rarityColor)
                }
                .padding()
                
                // Badge Description
                VStack(alignment: .leading, spacing: 15) {
                    Text(badge.description)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.accent3)
                        .cornerRadius(10)
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progress")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(badge.progress) / 100")
                            .font(.subheadline)
                        
                        ProgressBar(progress: Double(badge.progress) / 100.0)
                            .frame(height: 10)
                            .padding(.vertical, 5)
                    }
                    .padding()
                    .background(.accent3)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.background)
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
                    .foregroundColor(.main)
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
