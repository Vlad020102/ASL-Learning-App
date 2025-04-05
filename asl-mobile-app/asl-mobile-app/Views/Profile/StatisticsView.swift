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
    var questionsAnsweredTotal: Int
    var questionsAnsweredToday: Int
    var streak: Int
    var dailyGoal: Int
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                StatCard(icon: "flame.fill", iconColor: .orange, value: String(questionsAnsweredTotal), label: "Total Questions Answered")
                
                StatCard(icon: "bolt.fill", iconColor: .yellow, value: String(level), label: "Current Level")
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
                
                StatCard(icon: "rosette", iconColor: .gray, value: String(streak), label: "Streak")
                        .onTapGesture {
                            showingStreakCalendar = true
                        }
                }
        }
        .sheet(isPresented: $showingStreakCalendar) {
            StreakCalendarView()
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
