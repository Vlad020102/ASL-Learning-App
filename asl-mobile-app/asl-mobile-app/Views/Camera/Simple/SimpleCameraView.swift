//
//  CameraView.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 23.03.2025.
//
import SwiftUI
import AVFoundation

struct SimpleHostedViewController: UIViewControllerRepresentable {
    var modelType: String
    var targetSign: String
    var isCorrectSign: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = SimpleCameraViewController()
        if let cameraVC = cameraViewController as? SimpleCameraViewController {
                    cameraVC.setTargetSign(targetSign)
                    cameraVC.setModelType(modelType)
                }
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }

struct SimpleCameraView: View {
    @State var didTapCapture: Bool = false
    @Binding var targetSign: String
    @Binding var isCorrectSign: Bool
    
    var body: some View {
        ZStack {
            // Camera view controller
            SimpleHostedViewController(modelType: "Simple", targetSign: targetSign, isCorrectSign: isCorrectSign)
                .ignoresSafeArea()
                .onChange(of: targetSign) { newValue in
                    // Update the shared view model when target changes in UI
                    print(targetSign)
                    PredictionViewModel.shared.targetSign = newValue
                    PredictionViewModel.shared.updateMatchStatus()
                }
                .onReceive(PredictionViewModel.shared.$isCorrectSign) { newValue in
                    // Update the binding to propagate the correct status back
                    isCorrectSign = newValue
                }
            
            VStack {
                PredictionLabelView().padding(.horizontal)
                
                Spacer()
                
                // Capture button at the bottom
                CaptureButtonView()
                    .onTapGesture {
                        self.didTapCapture = true
                    }
                    .padding(.bottom, 10)
            }
        }
    }
}
