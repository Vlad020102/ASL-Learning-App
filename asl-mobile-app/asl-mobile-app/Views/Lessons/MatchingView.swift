import SwiftUI
import WebKit

struct MatchingView: View {
    let exercise: MatchingQuizData
    @State private var numberOfLives: Int = 5
    @State private var showCompletionView: Bool = false
    @State private var correctMatches: Int = 0
    @State private var attempts: Int = 0
    @State private var selectedLeftItem: Int? = nil
    @State private var selectedRightItem: Int? = nil
    @State private var correctPairs: [Int: Int] = [:]
    @State private var showFeedback: Bool = false
    @State private var feedbackType: SignView.FeedbackType = .incorrect
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 5) {
                if !showCompletionView {
                    // Progress bar and hearts - more compact
                    HStack {
                        ProgressView(value: Float(correctMatches) / Float(exercise.pairs.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
                            .frame(height: 8)
                            .padding(.horizontal)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(AppColors.primary)
                                .font(.system(size: 14))
                            Text("\(numberOfLives)")
                                .foregroundColor(AppColors.primary)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 2)
                    
                    Text("Tap the matching pairs")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, 5)
                    
                    // Matching exercise content with ScrollView for flexibility
                    ScrollView {
                        HStack(spacing: 15) {
                            // Left column (ASL signs as GIFs)
                            VStack(spacing: 10) {
                                ForEach(0..<exercise.pairs.count, id: \.self) { index in
                                    Button(action: {
                                        handleLeftSelection(index)
                                    }) {
                                        GIFView(
                                            gifName: exercise.pairs[index].signGif,
                                            shouldPlay: !correctPairs.contains(where: { $0.key == index })
                                        )
                                        .frame(width: (geometry.size.width - 50) / 3, height: (geometry.size.width - 50) / 3)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedLeftItem == index ? AppColors.primary : AppColors.border, lineWidth: 2)
                                        )
                                        .opacity(correctPairs.contains(where: { $0.key == index }) ? 0.6 : 1.0)
                                        .overlay(
                                            Group {
                                                if correctPairs.contains(where: { $0.key == index }) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(AppColors.primary)
                                                        .font(.system(size: 30))
                                                }
                                            }
                                        )
                                    }
                                    .disabled(correctPairs.contains(where: { $0.key == index }))
                                }
                            }
                            
                            // Right column (Text translations)
                            VStack(spacing: 10) {
                                ForEach(0..<exercise.pairs.count, id: \.self) { index in
                                    Button(action: {
                                        handleRightSelection(index)
                                    }) {
                                        Text(exercise.pairs[index].text)
                                            .font(.system(size: min(16, geometry.size.width / 25)))
                                            .padding(8)
                                            .frame(width: (geometry.size.width - 50) / 3, height: (geometry.size.width - 50) / 3)
                                            .background(correctPairs.contains(where: { $0.value == index }) ?
                                                AppColors.disabledBackground.opacity(0.7) : AppColors.disabledBackground)
                                            .foregroundColor(correctPairs.contains(where: { $0.value == index }) ? 
                                                AppColors.text.opacity(0.6) : AppColors.text)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedRightItem == index ? AppColors.primary : AppColors.border, lineWidth: 2)
                                            )
                                            .overlay(
                                                Group {
                                                    if correctPairs.contains(where: { $0.value == index }) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(AppColors.primary)
                                                            .font(.system(size: 30))
                                                    }
                                                }
                                            )
                                    }
                                    .disabled(correctPairs.contains(where: { $0.value == index }))
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 5)
                    
                    // Check button with safe area consideration
                } else {
                    // Completion view
                    QuizCompletionView(
                        isSuccess: numberOfLives > 0,
                        accuracy: Float(correctMatches) / Float(attempts),
                        livesRemaining: numberOfLives,
                        onRestart: {
                            let completeQuizData = CompleteQuizData.init(
                                quizID: Int(exercise.id),
                                score: String(Float(correctMatches) / Float(attempts)),
                                livesRemaining: numberOfLives,
                                status: numberOfLives > 0 ? .Completed : .Failed
                        )
                            print("Completing quiz with data: \(completeQuizData)")
                            NetworkService.shared.completeQuiz(data: completeQuizData) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let response):
                                        print("Quiz completed: \(response)")
                                        self.presentationMode.wrappedValue.dismiss()
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
        .sheet(isPresented: $showFeedback) {
            FeedbackView(
                feedbackType: $feedbackType,
                correctAnswer: nil,
                onContinue: {
                    if feedbackType == .correct {
                    } else {
                        selectedLeftItem = nil
                        selectedRightItem = nil
                    }
                    
                    if correctPairs.count == exercise.pairs.count {
                        showCompletionView = true
                    }
                    
                    showFeedback = false
                }
            )
        }
    }
    
    private var isCheckEnabled: Bool {
        selectedLeftItem != nil && selectedRightItem != nil
    }
    
    private func handleLeftSelection(_ index: Int) {
        if selectedLeftItem == index {
            selectedLeftItem = nil
        } else {
            selectedLeftItem = index
        }
        
        checkMatch()
    }
    
    private func handleRightSelection(_ index: Int) {
        if selectedRightItem == index {
            selectedRightItem = nil
        } else {
            selectedRightItem = index
        }

        checkMatch()
    }
    
    private func checkMatch() {
        guard let leftIndex = selectedLeftItem, let rightIndex = selectedRightItem else {
            return
        }
        
        attempts += 1
        let isMatch = exercise.pairs[leftIndex].matchIndex == rightIndex
        
        if isMatch {
            correctMatches += 1
            correctPairs[leftIndex] = rightIndex
            feedbackType = .correct
        } else {
            numberOfLives -= 1
            feedbackType = .incorrect
            
            if numberOfLives <= 0 {
                // Game over
                showCompletionView = true
                return
            }
        }
        
        showFeedback = true
        //reset values
        selectedLeftItem = nil
        selectedRightItem = nil
    }
}

struct GIFView: View {
    let gifName: String
    let shouldPlay: Bool
    
    init(gifName: String, shouldPlay: Bool = true) {
        self.gifName = gifName
        self.shouldPlay = shouldPlay
    }
    
    var body: some View {
        ZStack {
            GIFImageView(gifName: gifName, shouldPlay: shouldPlay)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
        }
    }
}

struct GIFImageView: UIViewRepresentable {
    let gifName: String
    let shouldPlay: Bool
    
    init(gifName: String, shouldPlay: Bool = true) {
        print(gifName)
        self.gifName = gifName
        self.shouldPlay = shouldPlay
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = Bundle.main.url(forResource: gifName, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        
        if shouldPlay {
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: URL(fileURLWithPath: "")
            )
        } else {
            webView.loadHTMLString("""
                <html>
                <head>
                    <style>
                        body { margin: 0; padding: 0; }
                        img { width: 100%; height: 100%; object-fit: contain; }
                    </style>
                </head>
                <body>
                    <img src="data:image/gif;base64,\(data.base64EncodedString())" style="animation-play-state: paused;">
                </body>
                </html>
            """, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if shouldPlay {
            uiView.reload()
        }
    }
}

extension MatchingView{
    static var mockExercise: MatchingQuizData {
        let pairs = [
            MatchingPair(signGif: "how-are-you", text: "hello", matchIndex: 1),
            MatchingPair(signGif: "how-are-you", text: "thank you", matchIndex: 3),
            MatchingPair(signGif: "how-are-you", text: "name", matchIndex: 2),
            MatchingPair(signGif: "how-are-you", text: "nice to meet you", matchIndex: 4),
            MatchingPair(signGif: "how-are-you", text: "how are you", matchIndex: 0)
        ]
        
        return MatchingQuizData(id: 1, title: "Matching Exercise", type: .Matching, status: .InProgress, score: 0.0, livesRemaining: 5, pairs: pairs)
    }
}

struct MatchingView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            MatchingView(exercise: MatchingView.mockExercise)
                .previewDisplayName("Default State")
        }
    }
}
