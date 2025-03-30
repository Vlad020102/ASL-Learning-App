//
//  CameraView.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 23.03.2025.
//
import SwiftUI
import AVFoundation

struct HostedViewController: UIViewControllerRepresentable {
    var targetSign: String
    var isCorrectSign: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = CameraViewController()
        if let cameraVC = cameraViewController as? CameraViewController {
                    cameraVC.setTargetSign(targetSign)
                }
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }


struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        Image(systemName: "video").font(.largeTitle)
            .padding(20)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.red)
                    .scaleEffect(animationAmount)
                    .opacity(Double(2 - animationAmount))
                    .animation(Animation.easeOut(duration: 1)
                        .repeatForever(autoreverses: false))
            )
            .onAppear
        {
            self.animationAmount = 2
        }
    }
}

struct LogoutButton: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        Button(action: {
            authManager.removeToken()
        }) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.headline)
                Text("Logout")
                    .fontWeight(.medium)
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(10)
        }
    }
}

struct CameraView: View {
    @State var didTapCapture: Bool = false
    @Binding var targetSign: String
    @Binding var isCorrectSign: Bool
    
    var body: some View {
        ZStack {
            // Camera view controller
            HostedViewController(targetSign: targetSign, isCorrectSign: isCorrectSign)
                .ignoresSafeArea()
                .onChange(of: targetSign) { newValue in
                    // Update the shared view model when target changes in UI
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
