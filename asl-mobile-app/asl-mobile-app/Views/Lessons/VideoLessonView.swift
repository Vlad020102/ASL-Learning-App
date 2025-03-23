import SwiftUI
import AVKit

// Define our lesson types
enum LessonType: String, Codable {
    case video
    // Can add more types in the future like image, text, etc.
}

// Define the structure for each lesson
struct Lesson: Identifiable, Codable {
    var id: UUID = UUID()
    var type: LessonType
    var question: String
    var correctAnswer: [String]
    var availableWords: [[String]]
    var videoFileName: String?
    var videoFileExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, question, correctAnswer, availableWords, videoFileName, videoFileExtension
    }
}

// Define the structure for the lesson collection
struct LessonCollection: Codable {
    var numberOfLessons: Int
    var lessons: [Lesson]
    
    static func loadFrom(jsonFileName: String) -> LessonCollection? {
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(LessonCollection.self, from: data)
    }
}

// Main lesson container view
struct LessonContainerView: View {
    let lessonCollection: LessonCollection
    @State private var currentLessonIndex: Int = 0
    @State private var numberOfLifes: Int = 5
    @State private var showCompletionView: Bool = false
    @State private var attempts: Int = 0
    @State private var correctAttempts: Int = 0
    
    var body: some View {
        VStack {
            if currentLessonIndex < lessonCollection.numberOfLessons && !showCompletionView {
                // Progress bar and hearts
                HStack {
                    ProgressView(value: Float(currentLessonIndex) / Float(lessonCollection.numberOfLessons))
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
                
                // Current lesson
                LessonView(
                    lesson: lessonCollection.lessons[currentLessonIndex],
                    numberOfLifes: $numberOfLifes,
                    onLessonComplete: {
                        correctAttempts += 1
                        attempts += 1
                        
                        if currentLessonIndex < lessonCollection.lessons.count - 1 {
                            currentLessonIndex += 1
                        } else {
                            showCompletionView = true
                        }
                    },
                    onLifeLost: {
                        attempts += 1
                        if numberOfLifes <= 0 {
                            // Handle game over scenario
                            showCompletionView = true
                        }
                        else {
                            numberOfLifes -= 1
                        }
                    }
                )
            } else {
                // Completion view when all lessons are done or lives are depleted
                LessonCompletionView(
                    isSuccess: numberOfLifes > 0,
                    accuracy: Float(correctAttempts) / Float(attempts),
                    livesRemaining: numberOfLifes,
                    onRestart: {
                        // Reset the state
                        currentLessonIndex = 0
                        numberOfLifes = 5
                        showCompletionView = false
                    }
                )
            }
        }
        .background(Color.gray.opacity(0.1))
    }
}

// This is the individual lesson view that adapts based on the lesson type
struct LessonView: View {
    let lesson: Lesson
    @Binding var numberOfLifes: Int
    let onLessonComplete: () -> Void
    let onLifeLost: () -> Void
    @State private var feedbackType: FeedbackType = .incorrect
    
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
            // Lesson title
            Text(lesson.question)
                .font(.headline)
                .padding(.top)
                .padding(.bottom, 10)
            
            // Content based on lesson type
            switch lesson.type {
            case .video:
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
            }
            
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
                ForEach(0..<lesson.availableWords.count, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<lesson.availableWords[row].count, id: \.self) { col in
                            if !lesson.availableWords[row][col].isEmpty {
                                Button(action: {
                                    // Add the word to the selected words
                                    selectedWords.append(lesson.availableWords[row][col])
                                }) {
                                    Text(lesson.availableWords[row][col])
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .disabled(selectedWords.contains(lesson.availableWords[row][col]))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                // Check if the answer is correct
                isCorrect = selectedWords == lesson.correctAnswer
                feedbackType = isCorrect ? .correct : .incorrect
                showFeedback = true
                
                if !isCorrect {
                    onLifeLost()
                }
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
        .onAppear {
            setupPlayer()
        }
        .sheet(isPresented: $showFeedback) {
            // Feedback popup
            FeedbackView(
                    feedbackType: $feedbackType,
                    correctAnswer: lesson.correctAnswer.joined(separator: " "),
                    onContinue: {
                        // Only complete lesson if correct
                        if feedbackType == .correct {
                            onLessonComplete()
                            selectedWords = []
                        }
                        showFeedback = false
                    }
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    
    private func setupPlayer() {
        guard let fileName = lesson.videoFileName,
              let fileExtension = lesson.videoFileExtension,
              let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            return
        }
        
        player = AVPlayer(url: url)
    }
}

struct FeedbackView: View {
    @Binding var feedbackType: LessonView.FeedbackType
    let correctAnswer: String
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feedbackType == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(feedbackType == .correct ? .green : .red)
            
            Text(feedbackType == .correct ? "Correct!" : "Try again!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(feedbackType == .correct ? "Great job understanding the sign!" : "The correct answer is: \(correctAnswer)")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: onContinue) {
                Text(feedbackType == .correct ? "Continue" : "Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(feedbackType == .correct ? Color.green : Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// View shown when all lessons are completed or when the player runs out of lives
struct LessonCompletionView: View {
    let isSuccess: Bool
    let accuracy: Float
    let livesRemaining: Int
    let onRestart: () -> Void
    
    init(isSuccess: Bool, accuracy: Float, livesRemaining: Int, onRestart: @escaping () -> Void) {
        self.isSuccess = isSuccess
        self.accuracy = accuracy
        self.livesRemaining = livesRemaining
        self.onRestart = onRestart
        
        print(accuracy)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: isSuccess ? "trophy.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(isSuccess ? .yellow : .red)
            
            Text(isSuccess ? "Great job!" : "Try again!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("Your score:")
                    .font(.headline)
                
                Text(accuracy > 0 ? "\(Int(accuracy * 100))%" : "0%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if isSuccess {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(livesRemaining) lives remaining")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            
            Button(action: onRestart) {
                Text("Start Over")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

// Preview helpers
struct LessonPreviewData {
    static let sampleLessonCollection = LessonCollection(
        numberOfLessons: 2,
        lessons: [
            Lesson(
                type: .video,
                question: "Translate this sign",
                correctAnswer: ["what's", "your", "name"],
                availableWords: [
                    ["meet", "name", "what's"],
                    ["you", "to", "where"],
                    ["your", "from", ""]
                ],
                videoFileName: "what-is-your-name",
                videoFileExtension: "mp4"
            ),
            Lesson(
                type: .video,
                question: "Translate this greeting",
                correctAnswer: ["nice", "to", "meet", "you"],
                availableWords: [
                    ["hello", "nice", "good"],
                    ["to", "for", "at"],
                    ["meet", "see", "know"],
                    ["you", "your", ""]
                ],
                videoFileName: "nice-to-meet-you",
                videoFileExtension: "mp4"
            )
        ]
    )
}

struct LessonContainerView_Previews: PreviewProvider {
    static var previews: some View {
        LessonContainerView(lessonCollection: LessonPreviewData.sampleLessonCollection)
    }
}
