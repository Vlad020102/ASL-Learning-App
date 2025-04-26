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

    // Time thresholds for performance calculation (in seconds)
    let excellentThreshold: TimeInterval = 1.5  // Excellent performance
    let goodThreshold: TimeInterval = 3.0       // Good performance
    let fairThreshold: TimeInterval = 5.0       // Fair performance
    let maxScoreableTime: TimeInterval = 10.0    // Maximum time that still gives points
    
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
                    // Update the binding to propagate the correct status back
                    isCorrectSign = newValue
                    if isCorrectSign {
                        let elapsedTime = Date().timeIntervalSince(startTime)
                        signTimes.append(elapsedTime)
                        moveToNextString()
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
