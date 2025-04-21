//
//  FeedbackView.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 04.04.2025.
//

import SwiftUI

struct FeedbackView: View {
    @Binding var feedbackType: SignView.FeedbackType
    let correctAnswer: String?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feedbackType == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(feedbackType == .correct ? .success : .error)
            
            Text(feedbackType == .correct ? "Correct!" : "Wrong Answer!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textSecondary)
            
            Text(feedbackType == .correct ? "Great job understanding the sign!" : "Try Again! Be careful not to run out of lives!")
                .multilineTextAlignment(.center)
                .foregroundColor(.textSecondary)
                .padding()
            
            Button(action: onContinue) {
                Text(feedbackType == .correct ? "Continue" : "Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(feedbackType == .correct ? .success : .accent1)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

// View shown when all Quizes are completed or when the player runs out of lives
struct QuizCompletionView: View {
    let isSuccess: Bool
    let accuracy: Float
    let livesRemaining: Int
    let onRestart: () -> Void
    
    init(isSuccess: Bool, accuracy: Float, livesRemaining: Int, onRestart: @escaping () -> Void) {
        self.isSuccess = isSuccess
        self.accuracy = accuracy
        self.livesRemaining = livesRemaining
        self.onRestart = onRestart
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: isSuccess ? "trophy.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(isSuccess ? .accent1 : .error)
            
            Text(isSuccess ? "Great job!" : "You have run out of lives!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textSecondary)
            
            VStack(spacing: 10) {
                Text("Your accuracy:")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                
                Text(accuracy > 0 ? "\(Int(accuracy * 100))%" : "0%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textSecondary)
                
                if isSuccess {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.success)
                        Text("\(livesRemaining) lives remaining")
                            .foregroundColor(.success)
                    }
                }
            }
            .padding()
            
            Button(action: onRestart) {
                Text("Quiz Catalogue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(.main)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

