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
            cardHeader
            quizTitle
            statusInfo
        }
        .padding()
        .background(AppColors.card)
        .cornerRadius(12)
        .shadow(color: AppColors.textSecondary.opacity(0.1), radius: 5, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
    
    private var cardHeader: some View {
        HStack {
            quizTypeLabel
            Spacer()
            statusIndicator
        }
    }
    
    private var quizTypeLabel: some View {
        Text(type.toString())
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(typeColor.opacity(0.2))
            .foregroundColor(typeColor)
            .cornerRadius(8)
    }
    
    private var statusIndicator: some View {
        Group {
            switch status {
            case .Completed:
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text("Completed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.success)
                }
            case .Failed:
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error)
                    Text("Failed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.error)
                }
            case .Locked:
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AppColors.textSecondary)
                    Text("Locked")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textSecondary)
                }
            case .InProgress:
                EmptyView()
            }
        }
    }
    
    private var quizTitle: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(AppColors.text)
            .lineLimit(2)
    }
    
    private var statusInfo: some View {
        Group {
            if status == .Completed || status == .Failed {
                VStack(alignment: .leading, spacing: 4) {
                    if type != .AlphabetStreak {
                        livesView
                    }
                    scoreView
                }
            }
        }
    }
    
    private var scoreView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(AppColors.accent1)
            
            if status == .Completed {
                Text("Score: \(Int(score * 100))%")
                    .font(.caption)
                    .foregroundColor(AppColors.text)
            } else {
                Text("Progress: \(score, specifier: "%.2f")%")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private var livesView: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundColor(AppColors.primary)
            Text("Lives: \(livesRemaining)/5")
                .font(.caption)
                .foregroundColor(status == .Completed ? AppColors.text : AppColors.textSecondary)
        }
    }
    
    private var typeColor: Color {
        switch (type, status) {
        case (.Bubbles, .InProgress):
            return AppColors.secondary
        case (.Matching, .InProgress):
            return AppColors.accent1
        case (.AlphabetStreak, .InProgress):
            return AppColors.primary
        default:
            return AppColors.text
        }
    }
}
