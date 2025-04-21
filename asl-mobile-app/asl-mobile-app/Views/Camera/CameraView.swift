//
//  CameraView.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 23.03.2025.
//
import SwiftUI
import AVFoundation
import Combine

// Custom notification name for camera cleanup
extension Notification.Name {
    static let cameraViewCleanup = Notification.Name("cameraViewCleanup")
}

class CameraViewControllerHolder: ObservableObject {
    @Published var controller: CameraViewController?
    
    // Track if cleanup is in progress to avoid duplicate calls
    private var isCleaningUp = false
    
    func createController(targetSign: String) {
        // Clean up existing controller first if it exists
        if let existingController = controller {
            print("🔴 Cleaning up existing controller before creating new one")
            existingController.shutdown()
            controller = nil
        }
        
        // Create new controller
        let newController = CameraViewController()
        newController.setTargetSign(targetSign)
        controller = newController
        print("🟢 Created new CameraViewController")
    }
    
    func cleanupController() {
        // Prevent multiple simultaneous cleanup calls
        guard !isCleaningUp else {
            print("⚠️ Cleanup already in progress, skipping")
            return
        }
        
        isCleaningUp = true
        print("🔴 Cleaning up CameraViewControllerHolder")
        
        if let existingController = controller {
            print("🔴 Calling shutdown on controller")
            existingController.shutdown()
            controller = nil
        } else {
            print("⚠️ No controller to clean up")
        }
        
        isCleaningUp = false
    }
    
    deinit {
        cleanupController()
        print("🔥 CameraViewControllerHolder deallocated")
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    var controllerHolder: CameraViewControllerHolder
    var targetSign: String
    var isCorrectSign: Bool
    
    init(controllerHolder: CameraViewControllerHolder, targetSign: String, isCorrectSign: Bool) {
        self.controllerHolder = controllerHolder
        self.targetSign = targetSign
        self.isCorrectSign = isCorrectSign
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        print("🟢 makeUIViewController called - creating or getting controller")
        if controllerHolder.controller == nil {
            controllerHolder.createController(targetSign: targetSign)
        }
        return controllerHolder.controller ?? UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Handle updates if needed
        if let cameraVC = uiViewController as? CameraViewController,
           cameraVC.targetSign != targetSign {
            cameraVC.setTargetSign(targetSign)
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        print("🔴 dismantleUIViewController called, cleaning up")
        if let cameraVC = uiViewController as? CameraViewController {
            cameraVC.shutdown()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        // Empty coordinator class
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

struct CameraView: View {
    @State var didTapCapture: Bool = false
    @Binding var targetSign: String
    @Binding var isCorrectSign: Bool
    
    // Create a holder that will live as long as this view
    @StateObject private var controllerHolder = CameraViewControllerHolder()
    
    // Track whether this view is currently visible
    @State private var isViewVisible = false
    
    var body: some View {
        ZStack {
            if isViewVisible {
                // Only create the hosted controller when view is active
                HostedViewController(
                    controllerHolder: controllerHolder,
                    targetSign: targetSign,
                    isCorrectSign: isCorrectSign
                )
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
            } else {
                // Placeholder when view is not active
                Color.black
                    .ignoresSafeArea()
                    .overlay(
                        Text("Camera initializing...")
                            .foregroundColor(.white)
                    )
            }
        }
        .onAppear {
            print("🟢 CameraView appeared")
            // Register for cleanup notifications
            NotificationCenter.default.addObserver(
                forName: .cameraViewCleanup,
                object: nil,
                queue: .main
            ) { _ in
                forceCleanup()
            }
            
            // Create controller when view appears
            isViewVisible = true
        }
        .onDisappear {
            print("🔴 CameraView disappeared")
            forceCleanup()
            
            // Remove notification observer
            NotificationCenter.default.removeObserver(
                self,
                name: .cameraViewCleanup,
                object: nil
            )
        }
    }
    
    // Function to ensure cleanup happens
    private func forceCleanup() {
        print("💥 Forcing camera cleanup")
        // 1. Mark view as not visible to prevent new frames
        isViewVisible = false
        
        // 2. Clean up controller
        controllerHolder.cleanupController()
        
        // 3. Reset prediction view model
        DispatchQueue.main.async {
            PredictionViewModel.shared.setPrediction("Waiting for hand...")
        }
        
        // 4. Force garbage collection (this helps)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🧹 Secondary cleanup finished")
        }
    }
}
