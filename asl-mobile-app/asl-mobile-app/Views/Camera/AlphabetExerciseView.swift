import SwiftUI

struct AlphabetExerciseView: View {
    @State private var currentIndex: Int = 0
    @State private var isCorrectSign: Bool = false
    @State private var targetSign: String = "Hello" // Start with the first string
    private let testStrings: [String] = ["Hello", "I Love You", "Wow", "No", "Yes"]
    
    var body: some View {
        ZStack {
            // Camera view
            HostedViewController(targetSign: targetSign, isCorrectSign: isCorrectSign)
                .ignoresSafeArea()
                .onChange(of: targetSign) { newValue in
                            // Update the shared view model when target changes in UI
                            PredictionViewModel.shared.setTargetSign(newValue)
                        }
                .onReceive(PredictionViewModel.shared.$isCorrectSign) { newValue in
                    // Update the binding to propagate the correct status back
                    isCorrectSign = newValue
                    if isCorrectSign {
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
                Text("Make the sign for: \(targetSign)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
        }
    }
    
    private func moveToNextString() {
        if currentIndex < testStrings.count - 1 {
            currentIndex += 1
            targetSign = testStrings[currentIndex]
            isCorrectSign = false // Reset the correctness for the next string
        } else {
            // Exercise complete
            print("Exercise complete!")
        }
    }
}
