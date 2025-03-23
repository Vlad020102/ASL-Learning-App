//
//  PredictionState.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 23.03.2025.
//

import SwiftUI

class PredictionViewModel: ObservableObject {
    @Published var prediction: String = "Waiting for hand..."
    @Published var targetSign: String = ""
    @Published var isCorrectSign: Bool = false

    static let shared = PredictionViewModel()
    
    func updateMatchStatus() {
            self.isCorrectSign = !targetSign.isEmpty && prediction == targetSign
        }
        
    // Override the prediction setter to check for matches
    func setPrediction(_ newPrediction: String) {
        prediction = newPrediction
        updateMatchStatus()
    }
    
    func setTargetSign(_ newTargetSign: String) {
        targetSign = newTargetSign
        updateMatchStatus()
    }
}


struct PredictionLabelView: View {
    @ObservedObject var viewModel = PredictionViewModel.shared
    
    var body: some View {
        VStack(spacing: 12) {
            // Show what sign to make
            if !viewModel.targetSign.isEmpty {
                Text("Target sign: \(viewModel.targetSign)")
                    .font(.system(size: 18, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Current prediction
            Text(viewModel.prediction)
                .font(.system(size: 24, weight: .bold))
                .padding()
                .background(
                    // Green background when correct, black otherwise
                    viewModel.isCorrectSign ?
                    Color.green.opacity(0.8) :
                        Color.black.opacity(0.7)
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                    
        }
        .padding(.top, 50)
    }
}
