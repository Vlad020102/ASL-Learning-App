//
//  LessonView.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 13.03.2025.
//

import SwiftUI
import AVKit

struct SignLanguageLesson: View {
    @State private var selectedWords: [String] = []
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "what-is-your-name", withExtension: "mp4") ?? URL(string: "about:blank")!)
    @State var isPlaying: Bool = false
    @State private var numberOfLifes = 5
    
    // Available words for constructing the answer
    let availableWords = [
        ["meet", "name", "what's"],
        ["you", "to", "where"],
        ["your", "from", ""]
    ]
    
    // The correct phrase for this lesson
    let correctAnswer = ["what's", "your", "name"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top progress bar and hearts
            HStack {
                ProgressView(value: 0.9)
                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                    .frame(height: 10)
                    .padding(.horizontal)
                
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(numberOfLifes)")
                        .foregroundColor(.red)
                }
                .padding(.trailing)
            }
            .padding()
            
            // Lesson title
            Text("Translate this sign")
                .font(.headline)
                .padding(.top)
                .padding(.bottom, 10)
            
            // Sign language image and context
            HStack(alignment: .top, spacing: 20) {
                // Replace the cartoon avatar with a sign language image
                VideoPlayer(player: player)
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing)
            }
            .padding()
            
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
                    // Clear the current selection
                    selectedWords.popLast()
                }) {
                    Image(systemName: "delete.backward")
                        .padding()
                }
            }
            .padding(.bottom)
            // User's answer field
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(height: 60)
                    .padding(.horizontal)
                
                if selectedWords.isEmpty {
                    Text("Tap the words to form your answer")
                        .foregroundColor(.gray.opacity(0.7))
                } else {
                    Text(selectedWords.joined(separator: " "))
                        .padding()
                }
            }
            .padding(.vertical)
            
            // Word selection grid
            VStack(spacing: 10) {
                ForEach(0..<availableWords.count, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<availableWords[row].count, id: \.self) { col in
                            if !availableWords[row][col].isEmpty {
                                Button(action: {
                                    // Add the word to the selected words
                                    selectedWords.append(availableWords[row][col])
                                }) {
                                    Text(availableWords[row][col])
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .disabled(selectedWords.contains(availableWords[row][col]))
                                
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Button(action: {
                // Check if the answer is correct
                isCorrect = selectedWords == correctAnswer
                showFeedback = true
                numberOfLifes -= 1
                
            }) {
                Text("CHECK")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedWords.isEmpty ? Color.gray.opacity(0.3) : Color.gray)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
            }
            .disabled(selectedWords.isEmpty)
            
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
        .sheet(isPresented: $showFeedback) {
            // Feedback popup
            VStack(spacing: 20) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Try again!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(isCorrect ? "Great job understanding the sign!" : "The correct answer is: what's your name")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    showFeedback = false
                    if isCorrect {
                        // Move to the next lesson if correct
                        selectedWords = []
                    }
                }) {
                    Text(isCorrect ? "Continue" : "Try Again")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(isCorrect ? Color.green : Color.blue)
                        .cornerRadius(25)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}

struct SignLanguageLesson_Previews: PreviewProvider {
    static var previews: some View {
        SignLanguageLesson()
    }
}
