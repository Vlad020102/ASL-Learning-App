import SwiftUI
import AVKit

class QuizViewModel: ObservableObject {
    @Published var quizes: [QuizData] = []
    
    func loadQuizes() {
        print("Loading quizes")
        NetworkService.shared.getQuiz() { [weak self] result in
            DispatchQueue.main.async {
                print(result)
                switch result {
                case .success(let response):
                    print("Quizes loaded: \(response.quizes)")
                    self?.quizes = response.quizes
                case .failure(let error):
                    print("Error loading quizes: \(error)")
                }
            }
        }
    }
}

struct QuizCatalogueView: View {
    @StateObject var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                AppColors.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    List {
                        ForEach(viewModel.quizes, id: \.id) { quiz in
                            quizCardView(for: quiz)
                        }
                        .listRowBackground(AppColors.background)
                    }
                    .onAppear {
                        viewModel.loadQuizes()
                    }
                    .listStyle(PlainListStyle())
                    .background(AppColors.background)
                }
            }
            .navigationTitle("Quizes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .foregroundStyle(AppColors.textSecondary)
        }
        .accentColor(AppColors.card) // Sets navigation link and button colors
    }
}

@ViewBuilder
private func quizCardView(for quiz: QuizData) -> some View {
    if quiz.status.toString() == "Locked" {
        QuizCard(quiz: quiz)
            .opacity(0.6)
    } else if quiz.status.toString() == "InProgress" {
        QuizCard(quiz: quiz)
    } else if quiz.status.toString() == "Completed" {
        QuizCard(quiz: quiz)
            .opacity(0.6)
    } else if quiz.status.toString() == "Failed" {
        QuizCard(quiz: quiz)
            .opacity(0.6)
    }
}
    

struct QuizCard: View {
    let quiz: QuizData
    
    var body: some View {
        NavigationLink(destination: QuizFlowView(quiz: quiz)) {
            VStack(alignment: .leading, spacing: 12) {
                // Card header with quiz type and status indicator
                HStack {
                    Text(quiz.type.toString())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(typeColor(for: quiz.type, status: quiz.status).opacity(0.2))
                        .foregroundColor(typeColor(for: quiz.type, status: quiz.status))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Status indicator
                    if quiz.status.toString() == "Completed" {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.success)
                            Text("Completed")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.success)
                        }
                    } else if quiz.status.toString() == "Failed" {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.error)
                            Text("Failed")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.error)
                        }
                    } else if quiz.status.toString() == "Locked" {
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
                Text(quiz.title)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
                
                // Show score and lives for completed quizzes
                if quiz.status.toString() == "Completed" {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(AppColors.accent1)
                            Text("Score: \(Int(quiz.score * 100))%")
                                .font(.caption)
                                .foregroundColor(AppColors.text)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundColor(AppColors.primary)
                            Text("Lives: \(quiz.livesRemaining)/5")
                                .font(.caption)
                                .foregroundColor(AppColors.text)
                        }
                    }
                }
                
                if quiz.status.toString() == "Failed" {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(AppColors.accent1)
                            Text("Progress: \(quiz.score, specifier: "%.2f")%")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundColor(AppColors.primary)
                            Text("Lives: \(quiz.livesRemaining)/5")
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
        .buttonStyle(PlainButtonStyle())
        .disabled(quiz.status.toString() == "Locked" ||
                  quiz.status.toString() == "Failed" ||
                  quiz.status.toString() == "Completed")
    }
    
    // Assign different colors based on quiz type
    private func typeColor(for type: QuizType, status: QuizStatus) -> Color {
        switch type {
        case .Bubbles:
            if(status == .InProgress){
                return AppColors.accent1
            }
            return AppColors.text
        }
    }
}
    
    

// Main Quiz container view
struct QuizFlowView: View {
    let quiz: QuizData
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
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                        .frame(height: 10)
                        .padding(.horizontal)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(AppColors.primary)
                        Text("\(numberOfLifes)")
                            .foregroundColor(AppColors.primary)
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
                            quizID: quiz.id,
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
        .background(AppColors.background)
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
                .foregroundColor(AppColors.textSecondary)
                .padding(.bottom, 10)
            
            // Content based on Quiz type
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.border, lineWidth: 1)
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
                    .stroke(AppColors.border, lineWidth: 1)
                    .frame(height: 60)
                    .padding(.horizontal)
                
                if selectedWords.isEmpty {
                    Text("Tap the words to form your answer")
                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                } else {
                    Text(selectedWords.joined(separator: " "))
                        .foregroundColor(AppColors.textSecondary)
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
                                        .background(AppColors.card)
                                        .foregroundColor(selectedWords.contains(word) ? AppColors.textSecondary: AppColors.text)
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
                isCorrect = selectedWords.joined(separator: " ") == sign?.text
                print(selectedWords)
                print(sign?.text)
                feedbackType = isCorrect ? .correct : .incorrect
                showFeedback = true
                
                if !isCorrect {
                    onLifeLost()
                }
            }) {
                Text("CHECK")
                    .fontWeight(.medium)
                    .foregroundColor(selectedWords.isEmpty ? AppColors.text : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedWords.isEmpty ? AppColors.disabledBackground : AppColors.primary)
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
                    correctAnswer: sign?.text,
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
            .background(AppColors.background)
        }
    
    private func setupPlayer() {
        guard let fileName = sign?.s3Url,
              let url = Bundle.main.url(forResource: "what-is-your-name", withExtension: ".mp4") else {
            return
        }
        
        player = AVPlayer(url: url)
    }
}

struct FeedbackView: View {
    @Binding var feedbackType: SignView.FeedbackType
    let correctAnswer: String?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feedbackType == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(feedbackType == .correct ? AppColors.success : AppColors.error)
            
            Text(feedbackType == .correct ? "Correct!" : "Wrong Answer!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textSecondary)
            
            Text(feedbackType == .correct ? "Great job understanding the sign!" : "Try Again! Be careful not to run out of lives!")
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.textSecondary)
                .padding()
            
            Button(action: onContinue) {
                Text(feedbackType == .correct ? "Continue" : "Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(feedbackType == .correct ? AppColors.success : AppColors.accent1)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
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
        
        print(accuracy)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: isSuccess ? "trophy.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(isSuccess ? AppColors.accent1 : AppColors.error)
            
            Text(isSuccess ? "Great job!" : "You have run out of lives!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textSecondary)
            
            VStack(spacing: 10) {
                Text("Your accuracy:")
                    .font(.headline)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(accuracy > 0 ? "\(Int(accuracy * 100))%" : "0%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textSecondary)
                
                if isSuccess {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(AppColors.success)
                        Text("\(livesRemaining) lives remaining")
                            .foregroundColor(AppColors.success)
                    }
                }
            }
            .padding()
            
            Button(action: onRestart) {
                Text("Quiz Catalogue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(AppColors.primary)
                    .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

struct QuizContainerView_Previews: PreviewProvider {
    static var previews: some View {
        QuizCatalogueView()
    }
}
