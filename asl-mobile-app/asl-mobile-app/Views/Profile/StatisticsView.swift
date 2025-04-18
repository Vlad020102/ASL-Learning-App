//
//  StatisticsView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 28.03.2025.
//

import SwiftUI

struct StatisticsView: View {
    @State private var showingStreakCalendar = false
    var level: Int
    var levelProgress: Double
    var questionsAnsweredTotal: Int
    var questionsAnsweredToday: Int
    var streak: Int
    var dailyGoal: Int
    
    private var totalPointsForLevel: Int {
        return 10 * (level + 1) // Level 3 needs 40 points, Level 4 needs 50 points
    }
    
    private var progressPercentage: Double {
        return min(levelProgress / Double(totalPointsForLevel), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                LevelStatCard(icon: "star.circle.fill", iconColor: .accent1, level: level, progress: levelProgress, totalPoints: totalPointsForLevel)
                
                StatCard(icon: "rosette", iconColor: .orange, value: String(questionsAnsweredTotal), label: "Total Questions Answered")
            }
            
            HStack(spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    StatCard(icon: "trophy.fill", iconColor: .yellow, value: "\(questionsAnsweredToday)/\(dailyGoal)", label: "Daily Goal")
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
                
                StatCard(icon: "flame.fill", iconColor: .red, value: String(streak), label: "Streak")
                        .onTapGesture {
                            showingStreakCalendar = true
                        }
                }
        }
        .sheet(isPresented: $showingStreakCalendar) {
            StreakCalendarView()
                .presentationDetents([.height(420)])
        }
        .padding(.bottom, 16)
    }
}

struct LevelStatCard: View {
    var icon: String
    var iconColor: Color
    var level: Int
    var progress: Double
    var totalPoints: Int
    
    init(icon: String, iconColor: Color, level: Int, progress: Double, totalPoints: Int) {
        self.icon = icon
        self.iconColor = iconColor
        self.level = level
        self.progress = progress.truncatingRemainder(dividingBy: 10.0)
        self.totalPoints = totalPoints
    }
    var progressPercentage: Double {
        return min(progress / 10.0, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
                
                Text("Level \(String(level))")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
            }
            
            Text("Progress: \(Int(progress)) / 10")
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 2) {
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accent1))
                    .frame(height: 6)
                
                HStack {
                    Text("\(level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(level+1)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.accent3)
        .cornerRadius(10)
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
                
            Spacer() // Add spacer to push content to the top
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.accent3)
        .cornerRadius(10)
    }
}
