//
//  BubblesVIew.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 04.04.2025.
//

import SwiftUI
import AVKit

struct BubblesView: View {
    let quiz: BubblesQuizData
    @State private var currentQuizIndex: Int = 0
    @State private var numberOfLifes: Int = 5
    @State private var showCompletionView: Bool = false
    @State private var attempts: Int = 0
    @State private var correctAttempts: Int = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if currentQuizIndex < quiz.signs?.count ?? 0 && !showCompletionView {
                // Progress bar and hearts
                HStack {
                    ProgressView(value: Float(currentQuizIndex) / Float(quiz.signs?.count ?? 0))
                        .progressViewStyle(LinearProgressViewStyle(tint: .main))
                        .frame(height: 10)
                        .padding(.horizontal)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.main)
                        Text("\(numberOfLifes)")
                            .foregroundColor(.main)
                    }
                    .padding(.horizontal, 5)
                }.padding(.top, 10)
                
                // Current Quiz
                SignView(
                    sign: quiz.signs?[currentQuizIndex],
                    numberOfLifes: $numberOfLifes,
                    onSignComplete: {
                        correctAttempts += 1
                        attempts += 1
                        
                        if currentQuizIndex < (quiz.signs?.count ?? 0) - 1 {
                            currentQuizIndex += 1
                        } else {
                            showCompletionView = true
                        }
                    },
                    onLifeLost: {
                        attempts += 1
                        numberOfLifes -= 1
                        if numberOfLifes == 0 {
                            // Handle game over scenario
                            showCompletionView = true
                        }
                    }
                )
            } else {
                // Completion view when all Quizes are done or lives are depleted
                QuizCompletionView(
                    isSuccess: numberOfLifes > 0,
                    accuracy: Float(correctAttempts) / Float(attempts),
                    livesRemaining: numberOfLifes,
                    onRestart: {
                       
                        let completeQuizData = CompleteQuizData.init(
                            quizID: Int(quiz.id),
                            score: String(Float(correctAttempts) / Float(attempts)),
                            livesRemaining: numberOfLifes,
                            status: numberOfLifes > 0 ? .Completed : .Failed
                        )
                        print("Completing quiz with data: \(completeQuizData)")
                        NetworkService.shared.completeQuiz(data: completeQuizData) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let response):
                                    print("Quiz completed: \(response)")
                                    self.presentationMode.wrappedValue.dismiss()
                                    currentQuizIndex = 0
                                    numberOfLifes = 5
                                    showCompletionView = false
                                case .failure(let error):
                                    self.presentationMode.wrappedValue.dismiss()
                                    print("Error completing quiz: \(error)")
                                }
                            }
                        }
                    }
                )
            }
        }
        .background(Color.background)
    }
}
//
struct SignView: View {
    let sign: Sign?
    @Binding var numberOfLifes: Int
    @State private var feedbackType: FeedbackType = .incorrect
    
    let onSignComplete: () -> Void
    let onLifeLost: () -> Void
    
    enum FeedbackType {
            case correct
            case incorrect
    }
    
    @State private var selectedWords: [String] = []
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Quiz title
            Text("What sign is this?")
                .font(.headline)
                .foregroundColor(.textSecondary)
                .padding(.bottom, 10)
            
            // Content based on Quiz type
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.border, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                HStack {
                    Button {
                        isPlaying ? player.pause() : player.play()
                        isPlaying.toggle()
                        player.seek(to: .zero)
                    } label: {
                        Image(systemName: isPlaying ? "stop" : "play")
                            .padding()
                    }
                    
                    Button(action: {
                        // Clear the last selected word
                        if !selectedWords.isEmpty {
                            selectedWords.removeLast()
                        }
                    }) {
                        Image(systemName: "delete.backward")
                            .padding()
                    }
                }
                .padding(.bottom)
            }
            
            // User's answer field
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.border, lineWidth: 1)
                    .frame(height: 60)
                    .padding(.horizontal)
                
                if selectedWords.isEmpty {
                    Text("Tap the words to form your answer")
                        .foregroundColor(.textSecondary.opacity(0.7))
                } else {
                    Text(selectedWords.joined(separator: " "))
                        .foregroundColor(.textSecondary)
                        .padding()
                }
            }
            .padding(.vertical)
            
            // Word selection grid
            VStack(spacing: 10) {
                ForEach(0..<(sign?.options?.split(separator: ",").count ?? 0), id: \.self) { row in
                    let rowOptions = sign?.options?.split(separator: ",")[row].split(separator: " ") ?? []
                    HStack(spacing: 10) {
                        ForEach(0..<rowOptions.count, id: \.self) { col in
                            let word = String(rowOptions[col])
                            if !word.isEmpty {
                                Button(action: {
                                    // Add the word to the selected words
                                    selectedWords.append(word)
                                }) {
                                    Text(word)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(.card)
                                        .foregroundColor(selectedWords.contains(word) ? .textSecondary: .text)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .disabled(selectedWords.contains(word))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                // Check if the answer is correct
                isCorrect = selectedWords.joined(separator: " ") == sign?.name
                feedbackType = isCorrect ? .correct : .incorrect
                showFeedback = true
                
                if !isCorrect {
                    onLifeLost()
                }
            }) {
                Text("CHECK")
                    .fontWeight(.medium)
                    .foregroundColor(selectedWords.isEmpty ? .text : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedWords.isEmpty ? .disabledBackground : .main)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
            .disabled(selectedWords.isEmpty)
        }
        .onAppear {
            setupPlayer()
        }
        .sheet(isPresented: $showFeedback) {
            // Feedback popup
            FeedbackView(
                    feedbackType: $feedbackType,
                    correctAnswer: sign?.name,
                    onContinue: {
                        // Only complete Quiz if correct
                        if feedbackType == .correct {
                            onSignComplete()
                            selectedWords = []
                        }
                        showFeedback = false
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
        }
    
    private func setupPlayer() {
        guard let fileName = sign?.s3Url,
              let url = Bundle.main.url(forResource: "what-is-your-name", withExtension: ".mp4") else {
            return
        }
        
        player = AVPlayer(url: url)
    }
}
