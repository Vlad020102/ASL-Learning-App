import SwiftUI
import WebKit

struct ASLMatchingExerciseView: View {
    let exercise: MatchingExerciseData
    @State private var numberOfLives: Int = 5
    @State private var showCompletionView: Bool = false
    @State private var correctMatches: Int = 0
    @State private var attempts: Int = 0
    @State private var selectedLeftItem: Int? = nil
    @State private var selectedRightItem: Int? = nil
    @State private var correctPairs: [Int: Int] = [:]
    @State private var showFeedback: Bool = false
    @State private var feedbackType: SignView.FeedbackType = .incorrect
    
    
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
//                            let completeExerciseData = CompleteExerciseData(
//                                exerciseId: exercise.id,
//                                score: String(Float(correctMatches) / Float(attempts)),
//                                livesRemaining: numberOfLives,
//                                status: numberOfLives > 0 ? .Completed : .Failed
//                            )
//                            
    //                        NetworkService.shared.completeExercise(data: completeExerciseData) { result in
    //                            DispatchQueue.main.async {
    //                                switch result {
    //                                case .success(let response):
    //                                    print("Exercise completed: \(response)")
    //                                    self.presentationMode.wrappedValue.dismiss()
    //                                case .failure(let error):
    //                                    self.presentationMode.wrappedValue.dismiss()
    //                                    print("Error completing exercise: \(error)")
    //                                }
    //                            }
    //                        }
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
                    // Reset selections after feedback
                    if feedbackType == .correct {
                        // Correct match already recorded in checkMatch()
                    } else {
                        // Wrong match
                        selectedLeftItem = nil
                        selectedRightItem = nil
                    }
                    
                    // Check if all pairs are matched
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
        // If the same item is tapped again, deselect it
        if selectedLeftItem == index {
            selectedLeftItem = nil
        } else {
            selectedLeftItem = index
        }
        
        // Remove automatic check when both sides are selected
        checkMatch()
    }
    
    private func handleRightSelection(_ index: Int) {
        // If the same item is tapped again, deselect it
        if selectedRightItem == index {
            selectedRightItem = nil
        } else {
            selectedRightItem = index
        }
        
        // Remove automatic check when both sides are selected
        checkMatch()
    }
    
    // This function was previously used for automatic checking
    // Now we'll only use it when the Check button is pressed
    private func checkMatch() {
        guard let leftIndex = selectedLeftItem, let rightIndex = selectedRightItem else {
            return
        }
        
        attempts += 1
        
        // Check if correct match (in this example, matching indexes are correct pairs)
        // In a real app, you'd check against actual matching pairs data
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

// GIF View Component
struct GIFView: View {
    let gifName: String
    let shouldPlay: Bool
    
    init(gifName: String, shouldPlay: Bool = true) {
        self.gifName = gifName
        self.shouldPlay = shouldPlay
    }
    
    var body: some View {
        // In a real implementation, you would use a GIF player
        // This is a placeholder that would be replaced with actual GIF functionality
        ZStack {
            GIFImageView(gifName, shouldPlay: shouldPlay)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
        }
    }
}

struct GIFImageView: UIViewRepresentable {
    let gifName: String
    let shouldPlay: Bool
    
    init(_ gifName: String, shouldPlay: Bool = true) {
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
            // Load the GIF as a static image by using HTML with CSS to pause it
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
        // Only reload if playing is enabled
        if shouldPlay {
            uiView.reload()
        }
    }
}

// Data models
struct MatchingExerciseData {
    let id: String
    let pairs: [MatchingPair]
}

struct MatchingPair {
    let signGif: String
    let text: String
    let matchIndex: Int  // Indicates the correct matching index
}

enum CompletionStatus {
    case Completed
    case Failed
}

struct CompleteExerciseData {
    let exerciseId: String
    let score: String
    let livesRemaining: Int
    let status: CompletionStatus
}


extension ASLMatchingExerciseView {
    static var mockExercise: MatchingExerciseData {
        let pairs = [
            MatchingPair(signGif: "how-are-you", text: "hello", matchIndex: 1),
            MatchingPair(signGif: "how-are-you", text: "thank you", matchIndex: 3),
            MatchingPair(signGif: "how-are-you", text: "name", matchIndex: 2),
            MatchingPair(signGif: "how-are-you", text: "nice to meet you", matchIndex: 4),
            MatchingPair(signGif: "how-are-you", text: "how are you", matchIndex: 0)
        ]
        
        return MatchingExerciseData(id: "exercise1", pairs: pairs)
    }
}

struct ASLMatchingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            ASLMatchingExerciseView(exercise: ASLMatchingExerciseView.mockExercise)
                .previewDisplayName("Default State")
        }
    }
}
