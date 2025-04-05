//
//  QuizCard.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 05.04.2025.
//

import SwiftUI

struct GenericQuizCard: View {
    let title: String
    let type: QuizType
    let status: QuizStatus
    let score: Double
    let livesRemaining: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header with quiz type and status indicator
            HStack {
                Text(type.toString())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(typeColor(for: type, status: status).opacity(0.2))
                    .foregroundColor(typeColor(for: type, status: status))
                    .cornerRadius(8)
                
                Spacer()
                
                // Status indicator
                if status.toString() == "Completed" {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                        Text("Completed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.success)
                    }
                } else if status.toString() == "Failed" {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.error)
                        Text("Failed")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.error)
                    }
                } else if status.toString() == "Locked" {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(AppColors.textSecondary)
                        Text("Locked")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Quiz title
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.text)
                .lineLimit(2)
            
            // Show score and lives for completed quizzes
            if status.toString() == "Completed" {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(AppColors.accent1)
                        Text("Score: \(Int(score * 100))%")
                            .font(.caption)
                            .foregroundColor(AppColors.text)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(AppColors.primary)
                        Text("Lives: \(livesRemaining)/5")
                            .font(.caption)
                            .foregroundColor(AppColors.text)
                    }
                }
            }
            
            if status.toString() == "Failed" {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(AppColors.accent1)
                        Text("Progress: \(score, specifier: "%.2f")%")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(AppColors.primary)
                        Text("Lives: \(livesRemaining)/5")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(12)
        .shadow(color: AppColors.textSecondary.opacity(0.1), radius: 5, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
       
    
    private func typeColor(for type: QuizType, status: QuizStatus) -> Color {
        switch type {
        case .Bubbles:
            if(status == .InProgress){
                return AppColors.accent1
            }
            return AppColors.text
        case .Matching:
            if(status == .InProgress){
                return AppColors.accent2
            }
            return AppColors.text
        }
    }
    
    private func getDestination(for quiz: BubblesQuizData) -> some View {
        switch quiz.type {
        case .Bubbles:
            return AnyView(BubblesView(quiz: quiz))
        case .Matching:
            return AnyView(Text("Matching Quiz Not Implemented Yet"))
        }
    }
}
