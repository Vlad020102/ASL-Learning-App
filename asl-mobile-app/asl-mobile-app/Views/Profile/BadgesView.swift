//
//  BadgesView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 28.03.2025.
//
import SwiftUI

struct BadgesView: View {
    let badges: [Badge]
    let title: String
    
    init(badges: [Badge], title: String = "Badges") {
        self.badges = badges.sorted { badge1, badge2 in
            let rarityOrder: [String: Int] = ["Bronze": 0, "Silver": 1, "Gold": 2]
            let value1 = rarityOrder[badge1.rarity] ?? 3
            let value2 = rarityOrder[badge2.rarity] ?? 3
            return value1 < value2
        }
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .foregroundColor(.alternative)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if badges.isEmpty {
                    Text("No badges found")
                        .foregroundColor(.alternative)
                        .font(.headline)
                        .bold(true)
                }
                ForEach(badges) { badge in
                    NavigationLink(destination: BadgeDetailView(badge: badge)) {
                        BadgeCard(badge: badge)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(.accent3)
        .cornerRadius(10)
        .toolbarBackground(Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    var rarityColor: Color {
        switch badge.rarity {
        case "Bronze": return .bronze
        case "Silver": return .silver
        case "Gold": return .gold
        default: return .gray
        }
    }
    
    @State private var isEffectActive = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .opacity(badge.status == "Locked" ? 0.5 : 1.0)
                    .symbolEffect(.scale, options: .speed(2), isActive: isEffectActive)
                    .foregroundColor(rarityColor)
                    .onTapGesture {
                        // Toggle the effect state when tapped
                        isEffectActive.toggle()
                    }
            }
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(height: 30)
            
            if badge.progress > 0 {
                ProgressView(value: Float(badge.progress) / 100.0, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accent1))
                    .frame(height: 4)
            } else {
                Spacer()
                    .frame(height: 4)
            }
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(Color.background)
        .cornerRadius(10)
    }
}
