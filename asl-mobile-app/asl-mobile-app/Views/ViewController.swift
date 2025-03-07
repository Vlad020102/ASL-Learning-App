//
//  ViewController.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 03.03.2025.
//


import UIKit
import SwiftUI
import AVFoundation
import Vision
import MediaPipeTasksVision



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, HandLandmarkerServiceLiveStreamDelegate {
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
    
    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil
    
    private var handLandmarkerService: HandLandmarkerService?
    private var currentTimeStamp: Int = 0
    
      
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        setupHandLandmarker()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // Reset layers when view reappears
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        
        
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
            case .authorized:
                permissionGranted = true
                
            // Permission has not been requested yet
            case .notDetermined:
                requestPermission()
                    
            default:
                permissionGranted = false
            }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
           
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
                         
        // Preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        previewLayer.connection?.videoOrientation = .portrait
        
        // Detector
        videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
    
    func setupHandLandmarker() {
        print("Setting up hand landmarker")
            // You'll need to provide a path to the hand landmarker model
            let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task")
            // Create a delegate for the hand landmarker (you'll need to implement this)
            let handLandmarkerDelegate = HandLandmarkerDelegate(name: "CPU")!
            
            // Create the hand landmarker service
            handLandmarkerService = HandLandmarkerService.liveStreamHandLandmarkerService(
                modelPath: modelPath,
                numHands: 2,
                minHandDetectionConfidence: 0.5,
                minHandPresenceConfidence: 0.5,
                minTrackingConfidence: 0.5,
                liveStreamDelegate: self,
                delegate: handLandmarkerDelegate
            )
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Get the sample buffer timestamp
        print("Capture output")
        currentTimeStamp = Int(Date().timeIntervalSince1970 * 1000)
        print(currentTimeStamp)
        
        // Process the sample buffer with the hand landmarker service
         handLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up, // Adjust this based on device orientation
            timeStamps: currentTimeStamp
        )
        
    }
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, didFinishDetection result: ResultBundle?, error: Error?) {
        guard let result = result, let handLandmarkerResult = result.handLandmarkerResults.first as? HandLandmarkerResult else {
            print("No hand landmarks detected")
            return
        }
        
        // Process the hand landmarks
        processHandLandmarks(handLandmarkerResult)
    }
    func processHandLandmarks(_ result: HandLandmarkerResult?) {
        // Print all the landmarks
        if let handLandmarks = result?.landmarks, !handLandmarks.isEmpty {
            for (index, landmarks) in handLandmarks.enumerated() {
                print("Hand \(index + 1) landmarks:")
                for (i, landmark) in landmarks.enumerated() {
                    print("Landmark \(i): x=\(landmark.x), y=\(landmark.y), z=\(landmark.z)")
                }
            }
        } else {
            print("No hand landmarks found")
        }
        // You can also visualize the landmarks by drawing them on a layer
        // This would require additional code to create a drawing layer
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
}

struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var body: some View {
        Image(systemName: "video").font(.largeTitle)
            .padding(30)
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
    var body: some View {
        HostedViewController()
            .ignoresSafeArea()
        CaptureButtonView().onTapGesture {
            self.didTapCapture = true
        }
    }
}
