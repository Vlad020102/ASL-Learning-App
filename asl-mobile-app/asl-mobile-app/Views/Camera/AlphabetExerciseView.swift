import SwiftUI

struct AlphabetExerciseView: View {
    let testStrings: [String]
    let quizID: Int
    @State var startSign: String
    @Environment(\.presentationMode) var presentationMode

    @State private var showCompletionView: Bool = false
    @State private var currentIndex: Int = 0
    @State private var isCorrectSign: Bool = false
    @State private var totalElapsedTime: TimeInterval = 0
    
    // Track timing for each sign separately
    @State private var signTimes: [TimeInterval] = []
    @State private var startTime: Date = Date()
    
    // New states for success animation and transition control
    @State private var showSuccessAnimation: Bool = false
    @State private var isValidationEnabled: Bool = true
    @State private var successMessage: String = "Well done!"

    // Time thresholds for performance calculation (in seconds)
    let excellentThreshold: TimeInterval = 1.5
    let goodThreshold: TimeInterval = 3.0
    let fairThreshold: TimeInterval = 5.0
    let maxScoreableTime: TimeInterval = 10.0
    
    var body: some View {
        ZStack {
            // Camera view
            SimpleHostedViewController(targetSign: startSign, isCorrectSign: isCorrectSign)
                .ignoresSafeArea()
                .onChange(of: startSign) { newValue in
                    // Update the shared view model when target changes in UI
                    PredictionViewModel.shared.setTargetSign(newValue)
                    startTime = Date()
                }
                .onReceive(PredictionViewModel.shared.$isCorrectSign) { newValue in
                    // Only process new correct predictions if validation is enabled
                    if newValue && isValidationEnabled {
                        isCorrectSign = newValue
                        let elapsedTime = Date().timeIntervalSince(startTime)
                        signTimes.append(elapsedTime)
                        
                        // Show success animation and disable validation
                        isValidationEnabled = false
                        showSuccessAnimation = true
                        
                        // Provide feedback based on performance
                        if elapsedTime <= excellentThreshold {
                            successMessage = "Excellent!"
                        } else if elapsedTime <= goodThreshold {
                            successMessage = "Great job!"
                        } else if elapsedTime <= fairThreshold {
                            successMessage = "Well done!"
                        } else {
                            successMessage = "Good!"
                        }
                        
                        // Add delay before moving to next sign
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            moveToNextString()
                            showSuccessAnimation = false
                            
                            // Re-enable validation after a short additional delay
                            // to prevent detecting the same sign for the new letter
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isValidationEnabled = true
                            }
                        }
                    }
                }
            
            VStack {
                // Carousel of test strings
                HStack(spacing: 20) {
                    let visibleIndices = (currentIndex - 1...currentIndex + 1).filter { $0 >= 0 && $0 < testStrings.count }
                    ForEach(visibleIndices, id: \.self) { index in
                        Text(testStrings[index])
                            .font(.system(size: 24, weight: .bold))
                            .padding()
                            .background(index == currentIndex ? Color.orange : Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                            .animation(.easeInOut, value: currentIndex)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Instruction
                Text("Make the sign for: \(startSign)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
            
            // Success animation overlay
            if showSuccessAnimation {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text(successMessage)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .transition(.scale.combined(with: .opacity))
                        
                        Text("Sign: \(startSign)")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                    .transition(.opacity)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showSuccessAnimation)
            }
            
            if showCompletionView {
                QuizCompletionView(
                    isSuccess: true,
                    accuracy: calculateAccuracy(),
                    livesRemaining: 5,
                    onRestart: {
                        let completeQuizData = CompleteQuizData(
                            quizID: quizID,
                            score: String(calculateAccuracy()),
                            livesRemaining: 5,
                            status: .Completed
                        )
                        
                        NetworkService.shared.completeQuiz(data: completeQuizData) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let response):
                                    self.presentationMode.wrappedValue.dismiss()
                                    currentIndex = 0
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
    }
    
    private func moveToNextString() {
        if currentIndex < testStrings.count - 1 {
            currentIndex += 1
            startSign = testStrings[currentIndex]
            isCorrectSign = false // Reset the correctness for the next string
        } else {
            showCompletionView = true
        }
    }
    
    private func calculateAccuracy() -> Float {
        guard !signTimes.isEmpty else { return 0.0 }
        
        // Calculate score for each sign based on completion time
        var totalScore: Float = 0.0
        
        for time in signTimes {
            let signScore: Float
            
            switch time {
            case ...excellentThreshold:
                // Excellent performance (1.0 - 0.9)
                signScore = 1.0
            case excellentThreshold...goodThreshold:
                // Good performance (0.9 - 0.7)
                // Linear interpolation between excellent and good thresholds
                let range = goodThreshold - excellentThreshold
                let position = time - excellentThreshold
                let percentage = Float(position / range)
                signScore = 0.9 - percentage * 0.2
            case goodThreshold...fairThreshold:
                // Fair performance (0.7 - 0.4)
                // Linear interpolation between good and fair thresholds
                let range = fairThreshold - goodThreshold
                let position = time - goodThreshold
                let percentage = Float(position / range)
                signScore = 0.7 - percentage * 0.3
            case fairThreshold...maxScoreableTime:
                // Poor but still scoreable performance (0.4 - 0.1)
                // Linear interpolation between fair threshold and max scoreable time
                let range = maxScoreableTime - fairThreshold
                let position = time - fairThreshold
                let percentage = Float(position / range)
                signScore = 0.4 - percentage * 0.3
            default:
                // Beyond max scoreable time
                signScore = 0.1
            }
            
            totalScore += signScore
        }
        
        // Calculate average score across all signs
        let averageScore = totalScore / Float(signTimes.count)
        
        return averageScore
    }
}
