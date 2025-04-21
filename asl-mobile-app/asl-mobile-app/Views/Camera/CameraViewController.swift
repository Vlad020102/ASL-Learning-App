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

protocol SignTargetDelegate {
    func setTargetSign(_ sign: String)
}


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,
                            HandLandmarkerServiceLiveStreamDelegate,
                            PoseLandmarkerServiceLiveStreamDelegate,
                            FaceLandmarkerServiceLiveStreamDelegate,
                            SignTargetDelegate {
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
    private var poseLandmarkerService: PoseLandmarkerService?
    private var faceLandmarkerService: FaceLandmarkerService?
    private var currentTimeStamp: Int = 0
    
    // Holistic model properties
    private var handResult: HandLandmarkerResult?
    private var poseResult: PoseLandmarkerResult?
    private var faceResult: FaceLandmarkerResult?
    
    // Sequence buffer for LSTM model (similar to the notebook)
    private var sequenceBuffer: [MLMultiArray] = []
    private let sequenceLength = 30 // Same as in the notebook
    
    // Add a synchronization queue to prevent race conditions
    private let sequenceBufferQueue = DispatchQueue(label: "com.aslapp.sequencebuffer")
    
    // Flag to track if the view is active
    private var isViewActive = false
    
    // Add property to track target sign
    var targetSign: String = ""
    
    // Track if shutdown has already been called
    private var isShutdown = false
    
    func setTargetSign(_ sign: String) {
        // Store locally and pass to prediction viewModel
        targetSign = sign
        PredictionViewModel.shared.targetSign = sign
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        print("Setup Landmarkers called")
        setupHandLandmarker()
        setupPoseLandmarker()
        setupFaceLandmarker()
        
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(appWillResignActive),
                                              name: UIApplication.willResignActiveNotification,
                                              object: nil)
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(appDidBecomeActive),
                                              name: UIApplication.didBecomeActiveNotification,
                                              object: nil)
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            // Don't start the session here, wait for viewDidAppear
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewActive = true
        // Start the capture session when view appears
        sessionQueue.async { [weak self] in
            guard let self = self, self.permissionGranted else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                print("Camera session started")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("🔴 CameraViewController viewWillDisappear")
        isViewActive = false
        stopAllProcessing()
        
        // Post notification to ensure cleanup
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .cameraViewCleanup, object: nil)
        }
    }
    
    deinit {
        print("🔥🔥🔥 CameraViewController DEALLOCATED 🔥🔥🔥")
        // Call shutdown in deinit as a final failsafe
        if !isShutdown {
            shutdown()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appWillResignActive() {
        stopAllProcessing()
    }
    
    @objc func appDidBecomeActive() {
        // Only restart if our view is currently visible
        if isViewActive {
            sessionQueue.async { [weak self] in
                guard let self = self, self.permissionGranted else { return }
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                    print("Camera session restarted after app became active")
                }
            }
        }
    }
    
    private func stopAllProcessing() {
        print("🔴 Stopping all camera processing")
        // Stop the capture session
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                print("Camera session stopped")
            }
        }
        
        // Clear all prediction data
        sequenceBufferQueue.async { [weak self] in
            guard let self = self else { return }
            self.sequenceBuffer.removeAll()
            self.handResult = nil
            self.poseResult = nil
            self.faceResult = nil
            print("Prediction data cleared")
        }
        
        // Clear UI elements on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.clearHandLandmarks()
            self.clearPoseLandmarks()
            self.clearFaceLandmarks()
        }
    }
    
    // Complete shutdown method for cleaning up all resources
    func shutdown() {
        // Prevent multiple calls to shutdown
        guard !isShutdown else {
            print("⚠️ Shutdown already called, skipping")
            return
        }
        
        print("🔴🔴🔴 COMPLETE SHUTDOWN OF CAMERA CONTROLLER 🔴🔴🔴")
        isShutdown = true
        
        // First, mark view as inactive to prevent new work
        isViewActive = false
        
        // Stop capturing
        stopAllProcessing()
        
        // Clean up notification observers
        NotificationCenter.default.removeObserver(self)
        
        // Release services on main thread to avoid threading issues
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Release services
            self.handLandmarkerService = nil
            self.poseLandmarkerService = nil
            self.faceLandmarkerService = nil
            
            // Clear all data references
            self.handResult = nil
            self.poseResult = nil
            self.faceResult = nil
            self.sequenceBuffer.removeAll()
            
            // Make sure prediction view is reset
            PredictionViewModel.shared.setPrediction("Camera stopped")
            
            // Force removal of preview layer
            self.previewLayer.removeFromSuperlayer()
            
            print("🔴 Camera controller shutdown complete")
        }
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
    
    func setupPoseLandmarker() {
        print("Setting up pose landmarker")
        let modelPath = Bundle.main.path(forResource: "pose_landmarker_lite", ofType: "task")
        let poseLandmarkerDelegate = PoseLandmarkerDelegate(name: "CPU")!
        
        poseLandmarkerService = PoseLandmarkerService.liveStreamPoseLandmarkerService(
            modelPath: modelPath,
            numPoses: 1,
            minPoseDetectionConfidence: 0.3,
            minPosePresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
            liveStreamDelegate: self,
            delegate: poseLandmarkerDelegate
        )
    }
    
    func setupFaceLandmarker() {
        print("Setting up face landmarker")
        let modelPath = Bundle.main.path(forResource: "face_landmarker", ofType: "task")
        let faceLandmarkerDelegate = FaceLandmarkerDelegate(name: "CPU")!
        
        faceLandmarkerService = FaceLandmarkerService.liveStreamFaceLandmarkerService(
            modelPath: modelPath,
            numFaces: 1,
            minFaceDetectionConfidence: 0.3,
            minFacePresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
            liveStreamDelegate: self,
            delegate: faceLandmarkerDelegate
        )
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Only process frames if the view is active
        guard isViewActive else { return }
        
        // Get the sample buffer timestamp
        currentTimeStamp = Int(Date().timeIntervalSince1970 * 1000)
        
        // Process the sample buffer with all landmarker services
        handLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up, // Adjust this based on device orientation
            timeStamps: currentTimeStamp
        )
        
        poseLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up,
            timeStamps: currentTimeStamp
        )
        
        faceLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up,
            timeStamps: currentTimeStamp
        )
    }
    
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, didFinishDetection result: HandResultBundle?, error: Error?) {
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
        
        // Store the hand landmark result
        handResult = handLandmarkerResult
        processHandLandmarks(handLandmarkerResult, in: self)
        
        // Try to make a holistic prediction whenever we get new hand data
        tryHolisticPrediction()
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
                
                
//                if !handLandmarks.isEmpty {
//                    for (index, landmarks) in handLandmarks.enumerated() {
//                        // Draw the landmarks
//                        self.drawHandLandmarks(landmarks, in: viewController.view, handIndex: index)
//                    }
//                }
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
    
    // MARK: - Pose Landmarker Delegate Methods
    func poseLandmarkerService(_ poseLandmarkerService: PoseLandmarkerService, didFinishDetection result: PoseResultBundle?, error: Error?) {
        guard let result = result, let poseLandmarkerResult = result.poseLandmarkerResults.first as? PoseLandmarkerResult else {
            self.clearPoseLandmarks()
            return
        }
        
        if poseLandmarkerResult.landmarks.isEmpty {
            self.clearPoseLandmarks()
            return
        }
        
        // Store the pose landmark result
        poseResult = poseLandmarkerResult
        processPoseLandmarks(poseLandmarkerResult, in: self)
        
        // Try to make a holistic prediction whenever we get new pose data
        tryHolisticPrediction()
    }
    
    func processPoseLandmarks(_ result: PoseLandmarkerResult?, in viewController: UIViewController) {
        if let poseLandmarks = result?.landmarks {
            DispatchQueue.main.async {
                if let vc = viewController as? CameraViewController {
                    self.clearPoseLandmarks()
                }
                
//                if !poseLandmarks.isEmpty {
//                    for landmarks in poseLandmarks {
//                        self.drawPoseLandmarks(landmarks, in: viewController.view)
//                    }
//                }
            }
        }
    }
    
    func clearPoseLandmarks() {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers {
                if layer.name == "poseLandmarksLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func drawPoseLandmarks(_ landmarks: [NormalizedLandmark], in view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "poseLandmarksLayer"
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.strokeColor = UIColor.green.cgColor
        
        view.layer.addSublayer(shapeLayer)
        
        let points = landmarks.map { landmark -> CGPoint in
            let xCoordinate = 1.0 - CGFloat(landmark.x)
            let yCoordinate = CGFloat(landmark.y)
            
            return CGPoint(
                x: xCoordinate * view.bounds.width,
                y: yCoordinate * view.bounds.height
            )
        }
        
        for point in points {
            let circlePath = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            
            let circleLayer = CAShapeLayer()
            circleLayer.name = "poseLandmarksLayer"
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.green.withAlphaComponent(0.5).cgColor
            
            view.layer.addSublayer(circleLayer)
        }
        
        drawPoseConnections(points: points, in: view)
    }
    
    func drawPoseConnections(points: [CGPoint], in view: UIView) {
        // Define pose connections based on MediaPipe pose landmarks
        let connections = [
            // Torso
            [11, 12], [12, 24], [24, 23], [23, 11],
            // Right arm
            [12, 14], [14, 16], [16, 18], [18, 20], [20, 22],
            // Left arm
            [11, 13], [13, 15], [15, 17], [17, 19], [19, 21],
            // Right leg
            [24, 26], [26, 28], [28, 30], [30, 32],
            // Left leg
            [23, 25], [25, 27], [27, 29], [29, 31],
            // Face
            [0, 1], [1, 2], [2, 3], [3, 7], [0, 4], [4, 5], [5, 6], [6, 8], [9, 10]
        ]
        
        for connection in connections {
            guard connection[0] < points.count, connection[1] < points.count else { continue }
            
            let startPoint = points[connection[0]]
            let endPoint = points[connection[1]]
            
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            let lineLayer = CAShapeLayer()
            lineLayer.name = "poseLandmarksLayer"
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.green.cgColor
            lineLayer.lineWidth = 2.0
            lineLayer.fillColor = UIColor.clear.cgColor
            
            view.layer.addSublayer(lineLayer)
        }
    }
    
    // MARK: - Face Landmarker Delegate Methods
    func faceLandmarkerService(_ faceLandmarkerService: FaceLandmarkerService, didFinishDetection result: FaceResultBundle?, error: Error?) {
        guard let result = result, let faceLandmarkerResult = result.faceLandmarkerResults.first as? FaceLandmarkerResult else {
            self.clearFaceLandmarks()
            return
        }
        
        if faceLandmarkerResult.faceLandmarks.isEmpty {
            self.clearFaceLandmarks()
            return
        }
        
        // Store the face landmark result
        faceResult = faceLandmarkerResult
        processFaceLandmarks(faceLandmarkerResult, in: self)
        
        // Try to make a holistic prediction whenever we get new face data
        tryHolisticPrediction()
    }
    
    func processFaceLandmarks(_ result: FaceLandmarkerResult?, in viewController: UIViewController) {
        if let faceLandmarks = result?.faceLandmarks {
            DispatchQueue.main.async {
                if let vc = viewController as? CameraViewController {
                    self.clearFaceLandmarks()
                }
                
//                if !faceLandmarks.isEmpty {
//                    for landmarks in faceLandmarks {
//                        self.drawFaceLandmarks(landmarks, in: viewController.view)
//                    }
//                }
            }
        }
    }
    
    func clearFaceLandmarks() {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers {
                if layer.name == "faceLandmarksLayer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func drawFaceLandmarks(_ landmarks: [NormalizedLandmark], in view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "faceLandmarksLayer"
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        
        view.layer.addSublayer(shapeLayer)
        
        let points = landmarks.map { landmark -> CGPoint in
            let xCoordinate = 1.0 - CGFloat(landmark.x)
            let yCoordinate = CGFloat(landmark.y)
            
            return CGPoint(
                x: xCoordinate * view.bounds.width,
                y: yCoordinate * view.bounds.height
            )
        }
        
        // For face landmarks, we'll only draw important points like eyes, nose, mouth
        // Instead of drawing all 468 landmarks
        let importantIndices = [
            33, 133, 362, 263, // Eyes
            1, 4, 5, 195, 197, // Nose
            61, 291, 0, 17, 57, 287 // Mouth
        ]
        
        for index in importantIndices {
            if index < points.count {
                let point = points[index]
                let circlePath = UIBezierPath(arcCenter: point, radius: 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                
                let circleLayer = CAShapeLayer()
                circleLayer.name = "faceLandmarksLayer"
                circleLayer.path = circlePath.cgPath
                circleLayer.fillColor = UIColor.yellow.withAlphaComponent(0.7).cgColor
                
                view.layer.addSublayer(circleLayer)
            }
        }
        
        drawFaceOutline(points: points, in: view)
    }
    
    func drawFaceOutline(points: [CGPoint], in view: UIView) {
        // Face outline connections
        // These are simplified for clarity - MediaPipe face mesh has many more connections
        let faceOutlineIndices = [
            10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288, 397, 365, 379, 378, 400, 377, 152, 148, 176, 149, 150, 136, 172, 58, 132, 93, 234, 127, 162, 21, 54, 103, 67, 109, 10
        ]
        
        let path = UIBezierPath()
        
        if let firstIndex = faceOutlineIndices.first, firstIndex < points.count {
            path.move(to: points[firstIndex])
            
            for i in 1..<faceOutlineIndices.count {
                let index = faceOutlineIndices[i]
                if index < points.count {
                    path.addLine(to: points[index])
                }
            }
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.name = "faceLandmarksLayer"
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.yellow.cgColor
        lineLayer.lineWidth = 1.5
        lineLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(lineLayer)
    }
    
    // Function to combine all landmarks, similar to extract_keypoints in the notebook
    func extractHolisticKeypoints() throws -> MLMultiArray {
        // Total dimensions based on the notebook:
        // Pose: 33 landmarks * 4 values (x,y,z,visibility) = 132
        // Face: 468 landmarks * 3 values (x,y,z) = 1404
        // Left hand: 21 landmarks * 3 values (x,y,z) = 63
        // Right hand: 21 landmarks * 3 values (x,y,z) = 63
        // Total: 1662
        
        let shape = [NSNumber(value: 1662)]
        let holisticArray = try MLMultiArray(shape: shape, dataType: .float32)
        
        var currentIndex = 0
        
        // Extract pose landmarks (33 landmarks * 4 values)
        if let pose = poseResult?.landmarks.first {
            // Safety check: make sure we have expected number of landmarks
            let poseCount = min(33, pose.count)
            for i in 0..<poseCount {
                let landmark = pose[i]
                // Safety check: ensure we don't exceed array bounds
                if currentIndex + 3 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                    holisticArray[currentIndex + 3] = landmark.visibility ?? 0.0
                }
                currentIndex += 4
            }
        } else {
            // Fill with zeros if no pose data
            let poseValues = 132
            for i in 0..<poseValues {
                if currentIndex < 1662 {
                    holisticArray[currentIndex] = 0.0
                }
                currentIndex += 1
            }
        }
        
        // Extract face landmarks (468 landmarks * 3 values)
        if let face = faceResult?.faceLandmarks.first {
            // Safety check: make sure we have expected number of landmarks
            let faceCount = min(468, face.count)
            for i in 0..<faceCount {
                let landmark = face[i]
                // Safety check: ensure we don't exceed array bounds
                if currentIndex + 2 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                }
                currentIndex += 3
            }
        } else {
            // Fill with zeros if no face data
            let faceValues = 1404
            for i in 0..<faceValues {
                if currentIndex < 1662 {
                    holisticArray[currentIndex] = 0.0
                }
                currentIndex += 1
            }
        }
        
        // Extract left hand landmarks (21 landmarks * 3 values)
        if let handLandmarks = handResult?.landmarks, handLandmarks.count > 0 {
            let leftHand = handLandmarks[0] // Assuming first hand is left
            // Safety check: make sure we have expected number of landmarks
            let leftHandCount = min(21, leftHand.count)
            for i in 0..<leftHandCount {
                let landmark = leftHand[i]
                // Safety check: ensure we don't exceed array bounds
                if currentIndex + 2 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                }
                currentIndex += 3
            }
        } else {
            // Fill with zeros if no left hand data
            let leftHandValues = 63
            for i in 0..<leftHandValues {
                if currentIndex < 1662 {
                    holisticArray[currentIndex] = 0.0
                }
                currentIndex += 1
            }
        }
        
        // Extract right hand landmarks (21 landmarks * 3 values)
        if let handLandmarks = handResult?.landmarks, handLandmarks.count > 1 {
            let rightHand = handLandmarks[1] // Assuming second hand is right
            // Safety check: make sure we have expected number of landmarks
            let rightHandCount = min(21, rightHand.count)
            for i in 0..<rightHandCount {
                let landmark = rightHand[i]
                // Safety check: ensure we don't exceed array bounds
                if currentIndex + 2 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                }
                currentIndex += 3
            }
        } else {
            // Fill with zeros if no right hand data
            let rightHandValues = 63
            for i in 0..<rightHandValues {
                if currentIndex < 1662 {
                    holisticArray[currentIndex] = 0.0
                }
                currentIndex += 1
            }
        }
        
        return holisticArray
    }
    
    // Function to make predictions using the holistic approach
    func tryHolisticPrediction() {
        // Only proceed if view is active and we have data
        guard isViewActive, (handResult != nil || poseResult != nil || faceResult != nil) else {
            return
        }
        
        do {
            // Extract holistic keypoints
            let keypoints = try extractHolisticKeypoints()
            
            // Use the synchronization queue for buffer access
            sequenceBufferQueue.async { [weak self] in
                guard let self = self else { return }
                
                // Add to sequence buffer
                self.sequenceBuffer.append(keypoints)
                
                // Keep only the last 30 frames (sequenceLength)
                if self.sequenceBuffer.count > self.sequenceLength {
                    self.sequenceBuffer.removeFirst()
                }
                
                // Only make a prediction when we have a full sequence
                if self.sequenceBuffer.count == self.sequenceLength {
                    // Copy the buffer to prevent race conditions
                    let bufferCopy = self.sequenceBuffer
                    
                    // Perform prediction on a background queue
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.predictFromSequence(with: bufferCopy)
                    }
                }
            }
        } catch {
            print("Error extracting holistic keypoints: \(error)")
        }
    }
    
    // Predict using sequence of holistic keypoints
    func predictFromSequence(with sequenceBuffer: [MLMultiArray]) {
        do {
            // Safety check
            guard sequenceBuffer.count == sequenceLength else {
                print("Sequence buffer length mismatch: \(sequenceBuffer.count) vs expected \(sequenceLength)")
                return
            }
            
            let config = MLModelConfiguration()
            
            // Use the holistic model
            let model = try ASLClassifierHolistic(configuration: config)
            
            // Create a combined multi-array for the sequence [1, 30, 1662]
            let sequenceShape = [NSNumber(value: 1), NSNumber(value: 30), NSNumber(value: 1662)]
            let sequenceMultiArray = try MLMultiArray(shape: sequenceShape, dataType: .float32)
            
            // Fill the sequence multi-array with our buffered frames
            for frameIndex in 0..<sequenceBuffer.count {
                // Ensure the frame exists
                guard frameIndex < sequenceBuffer.count else {
                    print("Frame index out of bounds: \(frameIndex), buffer size: \(sequenceBuffer.count)")
                    continue
                }
                
                let frame = sequenceBuffer[frameIndex]
                
                // Safety check for frame size
                let frameSize = min(frame.count, 1662)
                
                // Fill the sequence multi-array
                for keypointIndex in 0..<frameSize {
                    // Ensure the keypoint index is valid
                    guard keypointIndex < frame.count else {
                        print("Keypoint index out of bounds: \(keypointIndex), frame size: \(frame.count)")
                        continue
                    }
                    
                    do {
                        // Use 0 as first index (not 1) since array indices are 0-based
                        sequenceMultiArray[[0, frameIndex, keypointIndex] as [NSNumber]] = frame[keypointIndex]
                    } catch {
                        print("Error setting value at [\(0), \(frameIndex), \(keypointIndex)]: \(error)")
                        // Skip this element if there's an error
                        continue
                    }
                }
            }
            
            // Create the model input
            let input = ASLClassifierHolisticInput(lstm_3_input: sequenceMultiArray)
            
            // Make prediction
            let prediction = try model.prediction(input: input)
            
            // Log detailed prediction results
            if let identity = prediction.Identity as? MLMultiArray {
                print("🔍 PREDICTION DETAILS:")
                print("───────────────────────")
                
                // Print the raw prediction values for each class
                for i in 0..<min(3, identity.count) {
                    let classValue = identity[i].doubleValue
                    var className = "Unknown"
                    
                    switch i {
                    case 0: className = "hello"
                    case 1: className = "thanks"
                    case 2: className = "iloveyou"
                    default: className = "class_\(i)"
                    }
                    
                    let percentage = classValue * 100
                    print("📊 \(className): \(String(format: "%.2f", percentage))%")
                }
                
                if let argmax = try? self.getArgmax(identity) {
                    print("🏆 Top class: \(argmax) with confidence: \(String(format: "%.2f", identity[argmax].doubleValue * 100))%")
                }
                print("───────────────────────")
            }
            
            // Update UI with prediction - properly handle the output format
            DispatchQueue.main.async {
                // Define a default prediction in case we can't extract one
                var predictedSign = "Unknown"
                
                // Attempt to extract prediction from model output
                if let identity = prediction.Identity as? MLMultiArray {
                    // Safely get argmax
                    do {
                        if let argmax = try self.getArgmax(identity) {
                            // If Identity is a multi-array, find the index with highest probability
                            switch argmax {
                            case 0: predictedSign = "hello"
                            case 1: predictedSign = "thanks"
                            case 2: predictedSign = "iloveyou"
                            default: predictedSign = "Unknown sign \(argmax)"
                            }
                        }
                    } catch {
                        print("Error getting argmax: \(error)")
                    }
                } else if let classLabelProperty = prediction.Identity as? String {
                    // If Identity is a string, use it directly
                    predictedSign = classLabelProperty
                }
                
                // Update the UI with our prediction
                PredictionViewModel.shared.setPrediction(predictedSign)
            }
        } catch {
            print("Error predicting with holistic model: \(error)")
            DispatchQueue.main.async {
                PredictionViewModel.shared.setPrediction("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper function to safely find the index with highest value
    func getArgmax(_ array: MLMultiArray) -> Int? {
        guard array.count > 0 else { return nil }
        
        var maxIndex = 0
        var maxValue = array[0].doubleValue
        
        for i in 1..<array.count {
            let value = array[i].doubleValue
            if value > maxValue {
                maxValue = value
                maxIndex = i
            }
        }
        
        return maxIndex
    }
}
