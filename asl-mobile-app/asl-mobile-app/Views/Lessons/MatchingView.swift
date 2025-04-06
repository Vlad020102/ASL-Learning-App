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
                    topProgressBar
                    
                    Text("Tap the matching pairs")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, 5)
                    
                    // Matching exercise content with ScrollView for flexibility
                    matchingContent(geometry: geometry)
                    
                } else {
                    // Completion view
                    quizCompletionView
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
                        // Do nothing here since we've already handled the match
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
    
    // MARK: - Extracted Views
    
    private var topProgressBar: some View {
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
    }
    
    private func matchingContent(geometry: GeometryProxy) -> some View {
        ScrollView {
            HStack(spacing: 15) {
                // Left column (ASL signs as GIFs)
                VStack(spacing: 10) {
                    ForEach(0..<exercise.pairs.count, id: \.self) { index in
                        leftItemButton(index: index, geometry: geometry)
                    }
                }
                
                // Right column (Text translations)
                VStack(spacing: 10) {
                    ForEach(0..<exercise.pairs.count, id: \.self) { index in
                        rightItemButton(index: index, geometry: geometry)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 5)
    }
    
    private func leftItemButton(index: Int, geometry: GeometryProxy) -> some View {
        let isCompleted = correctPairs.contains(where: { $0.key == index })
        let itemSize = (geometry.size.width - 50) / 3
        
        return Button(action: {
            handleLeftSelection(index)
        }) {
            GIFView(
                gifName: exercise.pairs[index].signGif,
            )
            .frame(width: itemSize, height: itemSize)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedLeftItem == index ? AppColors.primary : AppColors.border, lineWidth: 2)
            )
            .opacity(isCompleted ? 0.6 : 1.0)
            .overlay(leftItemCheckmark(index: index))
        }
        .disabled(isCompleted)
    }
    
    private func leftItemCheckmark(index: Int) -> some View {
        Group {
            if correctPairs.contains(where: { $0.key == index }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 30))
            }
        }
    }
    
    private func rightItemButton(index: Int, geometry: GeometryProxy) -> some View {
        let isCompleted = correctPairs.contains(where: { $0.value == index })
        let itemSize = (geometry.size.width - 50) / 3
        let backgroundColor = isCompleted ? AppColors.disabledBackground.opacity(0.7) : AppColors.disabledBackground
        let textColor = isCompleted ? AppColors.text.opacity(0.6) : AppColors.text
        
        return Button(action: {
            handleRightSelection(index)
        }) {
            Text(exercise.pairs[index].text)
                .font(.system(size: min(16, geometry.size.width / 25)))
                .padding(8)
                .frame(width: itemSize, height: itemSize)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedRightItem == index ? AppColors.primary : AppColors.border, lineWidth: 2)
                )
                .overlay(rightItemCheckmark(index: index))
        }
        .disabled(isCompleted)
    }
    
    private func rightItemCheckmark(index: Int) -> some View {
        Group {
            if correctPairs.contains(where: { $0.value == index }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 30))
            }
        }
    }
    
    private var quizCompletionView: some View {
        QuizCompletionView(
            isSuccess: numberOfLives > 0,
            accuracy: Float(correctMatches) / Float(attempts),
            livesRemaining: numberOfLives,
            onRestart: {
                let completeQuizData = CompleteQuizData(
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
    
    // MARK: - Helper Methods
    
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
    
    init(gifName: String, shouldPlay: Bool = true) {
        self.gifName = gifName
    }
    
    var body: some View {
        ZStack {
            GIFImageView(gifName: gifName)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
        }
    }
}

struct GIFImageView: UIViewRepresentable {
    let gifName: String
    
    init(gifName: String) {
        print(gifName)
        self.gifName = gifName
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let url = Bundle.main.url(forResource: gifName, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: URL(fileURLWithPath: "")
        )
      
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
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
