//
//  ViewController.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 03.03.2025
//


import UIKit
import SwiftUI
import AVFoundation
import Vision
import MediaPipeTasksVision

protocol SignTargetDelegate {
    func setTargetSign(_ sign: String)
}


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, HandLandmarkerServiceLiveStreamDelegate, SignTargetDelegate {
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
    
    
    func setTargetSign(_ sign: String) {
            // Pass the target sign to the prediction viewModel
            PredictionViewModel.shared.targetSign = sign
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        print("Setup Hand Landmarker called")
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
        captureSession.stopRunning()
        
        // Remove existing inputs
        if let currentInput = captureSession.inputs.first {
            captureSession.removeInput(currentInput)
        }
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }

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
            minHandDetectionConfidence: 0.3,
            minHandPresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
            liveStreamDelegate: self,
            delegate: handLandmarkerDelegate
        )
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Get the sample buffer timestamp
        currentTimeStamp = Int(Date().timeIntervalSince1970 * 1000)
        
        // Process the sample buffer with the hand landmarker service
        handLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up, // Adjust this based on device orientation
            timeStamps: currentTimeStamp
        )
        
    }
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, didFinishDetection result: ResultBundle?, error: Error?) {
        guard let result = result, let handLandmarkerResult = result.handLandmarkerResults.first as? HandLandmarkerResult else {
            DispatchQueue.main.async {
                        PredictionViewModel.shared.setPrediction("No hand detected")
            }
            self.clearHandLandmarks()
            return
        }
        
        if handLandmarkerResult.landmarks.isEmpty {
            DispatchQueue.main.async {
                PredictionViewModel.shared.setPrediction("No hand detected")
            }
            self.clearHandLandmarks()
            return
        }
        
        processHandLandmarks(handLandmarkerResult, in: self)
        do{
            let config = MLModelConfiguration()
            let model = try ASLClassifier(configuration: config)
            
            let input: ASLClassifierInput = try ASLClassifierInput(input: convertLandmarksToMLMultiArray(results: handLandmarkerResult))
            let prediction: ASLClassifierOutput = try model.prediction(input: input)
            
            
            DispatchQueue.main.async {
                PredictionViewModel.shared.setPrediction(prediction.classLabel)
            }
        }
        catch(let error){
            print("Error: \(error)")
            DispatchQueue.main.async {
                PredictionViewModel.shared.setPrediction("Error: Unable to classify")
           }
        }
    }
    
    func convertLandmarksToMLMultiArray(results: HandLandmarkerResult?) throws -> MLMultiArray {
        guard let multiHandLandmarks = results?.landmarks, !multiHandLandmarks.isEmpty else {
            let multiArray = try MLMultiArray(shape: [42], dataType: .double)
                
                // Initialize all values to 0
                for i in 0..<42 {
                    multiArray[i] = 0.0 as NSNumber
                }
            return multiArray
        }
        // Process each hand's landmarks
        for handLandmarks in results!.landmarks {
            // Find minimum x and y to normalize positions
            var minY: Float = Float.greatestFiniteMagnitude
            var minX: Float = Float.greatestFiniteMagnitude
            
            // Find the minimum x and y values across all landmarks in this hand
            for landmark in handLandmarks {
                minY = min(minY, landmark.y)
                minX = min(minX, landmark.x)
            }
            
            // Create normalized data by subtracting min values
            var dataAux: [[Float]] = []
            for landmark in handLandmarks {
                dataAux.append([landmark.y - minY, landmark.x - minX])
            }
            
            // Flatten the data (equivalent to flattened_data_aux in Python)
            var flattenedDataAux: [Float] = []
            for point in dataAux {
                flattenedDataAux.append(contentsOf: point)
            }
            // Convert the flattened data to MLMultiArray
            let multiArray = try MLMultiArray(shape: [NSNumber(value: flattenedDataAux.count)], dataType: .float32)
            
            // Fill the MLMultiArray with the normalized values
            for i in 0..<flattenedDataAux.count {
                multiArray[i] = NSNumber(value: flattenedDataAux[i])
            }
            
            return multiArray
        }
        let multiArray = try MLMultiArray(shape: [42], dataType: .double)
            
            // Initialize all values to 0
            for i in 0..<42 {
                multiArray[i] = 0.0 as NSNumber
            }
        return multiArray
    }
    func processHandLandmarks(_ result: HandLandmarkerResult?, in viewController: UIViewController) {
        // Get the result and pass it to main thread for UI updates
        if let handLandmarks = result?.landmarks {
            DispatchQueue.main.async {
                // Get the view from the view controller on the main thread
                if let vc = viewController as? CameraViewController {
                                self.clearHandLandmarks()
                            }
                
                
                if !handLandmarks.isEmpty {
                    for (index, landmarks) in handLandmarks.enumerated() {
                        // Draw the landmarks
                        self.drawHandLandmarks(landmarks, in: viewController.view, handIndex: index)
                    }
                }
            }
        }
    }
    
    func clearHandLandmarks() {
            // Remove all layers with the name "handLandmarksLayer"
            if let sublayers = view.layer.sublayers {
                for layer in sublayers {
                    if layer.name == "handLandmarksLayer" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    
    func drawHandLandmarks(_ landmarks: [NormalizedLandmark], in view: UIView, handIndex: Int) {
        // Create a shape layer for drawing
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "handLandmarksLayer"
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeColor = (handIndex == 0) ? UIColor.red.cgColor : UIColor.blue.cgColor
        
        // Add layer to the view
        view.layer.addSublayer(shapeLayer)
        
        // Convert normalized coordinates to view coordinates
        let points = landmarks.map { landmark -> CGPoint in
            // For front camera, flip the x coordinate horizontally
            let xCoordinate = 1.0 - CGFloat(landmark.x)
            let yCoordinate = CGFloat(landmark.y)
            
            return CGPoint(
                x: xCoordinate * view.bounds.width,
                y: yCoordinate * view.bounds.height
            )
        }
        
        // Draw landmarks as circles
        for point in points {
            let circlePath = UIBezierPath(arcCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            
            let circleLayer = CAShapeLayer()
            circleLayer.name = "handLandmarksLayer"
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = (handIndex == 0) ? UIColor.red.withAlphaComponent(0.5).cgColor : UIColor.blue.withAlphaComponent(0.5).cgColor
            
            view.layer.addSublayer(circleLayer)
        }
        
        // Draw connections between landmarks (hand skeleton)
        drawHandConnections(points: points, in: view, handIndex: handIndex)
    }


    func drawHandConnections(points: [CGPoint], in view: UIView, handIndex: Int) {
        // Define the connections for a hand
        // These index pairs represent which landmarks should be connected with lines
        // Based on MediaPipe hand landmark model (21 landmarks)
        let connections = [
            // Thumb
            [0, 1], [1, 2], [2, 3], [3, 4],
            // Index finger
            [0, 5], [5, 6], [6, 7], [7, 8],
            // Middle finger
            [0, 9], [9, 10], [10, 11], [11, 12],
            // Ring finger
            [0, 13], [13, 14], [14, 15], [15, 16],
            // Pinky
            [0, 17], [17, 18], [18, 19], [19, 20],
            // Palm connections
            [5, 9], [9, 13], [13, 17]
        ]
        
        for connection in connections {
            // Ensure indices are valid
            guard connection[0] < points.count, connection[1] < points.count else { continue }
            
            let startPoint = points[connection[0]]
            let endPoint = points[connection[1]]
            
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            let lineLayer = CAShapeLayer()
            lineLayer.name = "handLandmarksLayer"
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = (handIndex == 0) ? UIColor.red.cgColor : UIColor.blue.cgColor
            lineLayer.lineWidth = 2.0
            lineLayer.fillColor = UIColor.clear.cgColor
            
            view.layer.addSublayer(lineLayer)
        }
    }
}
