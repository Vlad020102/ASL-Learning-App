//
//  BadgesView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 28.03.2025.
//
import SwiftUI

struct BadgesView: View {
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badges")
                .foregroundColor(AppColors.secondary)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
        }
        .padding()
        .background(AppColors.accent3)
        .cornerRadius(10)
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    var rarityColor: Color {
        switch badge.rarity {
        case "Bronze": return .brown
        case "Silver": return .gray
        case "Gold": return .yellow
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image("level_silver_25")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .opacity(badge.status == "Locked" ? 0.5 : 1.0)
            }
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(badge.status == "Locked" ? .gray : .primary)
            
            if badge.progress > 0 {
                ProgressView(value: Float(badge.progress))
                    .progressViewStyle(LinearProgressViewStyle(tint: rarityColor))
                    .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.background)
        .cornerRadius(10)
    }
}
