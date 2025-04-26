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

// Structure to hold results for a single timestamp
struct AggregatedResults {
    var handResult: HandLandmarkerResult?
    var poseResult: PoseLandmarkerResult?
    var faceResult: FaceLandmarkerResult?
    // var timestamp: Int // Milliseconds - No longer needed here
}

class HolisticCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,
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
    private var handResult: HandLandmarkerResult? // Keep for drawing if needed, but not primary for prediction logic
    private var poseResult: PoseLandmarkerResult? // Keep for drawing if needed
    private var faceResult: FaceLandmarkerResult? // Keep for drawing if needed
    
    // Sequence buffer for LSTM model (similar to the notebook)
    private var sequenceBuffer: [MLMultiArray] = []
    private let sequenceLength = 30 // Same as in the notebook
    private let keypointQualityThreshold = 1500 // Minimum non-zero keypoints for a frame to be valid (tune this value)
    
    // Add a synchronization queue to prevent race conditions
    private let sequenceBufferQueue = DispatchQueue(label: "com.aslapp.sequencebuffer")
    private let resultsAggregatorQueue = DispatchQueue(label: "com.aslapp.resultsaggregator")

    // Dictionary to aggregate results by timestamp
    private var resultsAggregator: [Int: AggregatedResults] = [:]
    
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
        stopAllProcessing() // This now also clears the aggregator
        
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
        
        // Clear prediction data and aggregator
        sequenceBufferQueue.async { [weak self] in
            guard let self = self else { return }
            self.sequenceBuffer.removeAll()
            print("Sequence buffer cleared")
        }
        resultsAggregatorQueue.async { [weak self] in
            guard let self = self else { return }
            self.resultsAggregator.removeAll()
            self.handResult = nil // Also clear individual results used for drawing
            self.poseResult = nil
            self.faceResult = nil
            print("Results aggregator cleared")
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
        
        // Stop capturing and clear data (includes aggregator)
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
            
            // Clear all data references (already done in stopAllProcessing, but good to be explicit)
            self.handResult = nil
            self.poseResult = nil
            self.faceResult = nil
            self.sequenceBuffer.removeAll()
            self.resultsAggregator.removeAll()
            
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
        
        // Get the sample buffer timestamp (use CMSampleBuffer's timestamp for better accuracy)
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let currentFrameTimestamp = Int(CMTimeGetSeconds(time) * 1000) // Convert to milliseconds
        
        // Process the sample buffer with all landmarker services using the same timestamp
        handLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up,
            timeStamps: currentFrameTimestamp // Use frame timestamp
        )
        
        poseLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up,
            timeStamps: currentFrameTimestamp // Use frame timestamp
        )
        
        faceLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up,
            timeStamps: currentFrameTimestamp // Use frame timestamp
        )
    }
    
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, didFinishDetection result: HandResultBundle?, timestampInMilliseconds: Int, error: Error?) {
        guard let result = result, let handLandmarkerResult = result.handLandmarkerResults.first as? HandLandmarkerResult else {
            // Still update UI if needed, but handle potential nil result in aggregation
            DispatchQueue.main.async {
                PredictionViewModel.shared.setPrediction("No hand detected")
                self.clearHandLandmarks()
            }
            // Store nil result for this timestamp if an error occurred or no detection
            storeResult(timestamp: timestampInMilliseconds, handResult: nil)
            return
        }
        
        // Store the valid hand landmark result for drawing/UI update
        self.handResult = handLandmarkerResult // Keep for drawing
        
        // Store the result in the aggregator
        storeResult(timestamp: timestampInMilliseconds, handResult: handLandmarkerResult)
    }
    
    func poseLandmarkerService(_ poseLandmarkerService: PoseLandmarkerService, didFinishDetection result: PoseResultBundle?, timestampInMilliseconds: Int, error: Error?) {
        guard let result = result, let poseLandmarkerResult = result.poseLandmarkerResults.first as? PoseLandmarkerResult else {
            DispatchQueue.main.async { self.clearPoseLandmarks() }
            storeResult(timestamp: timestampInMilliseconds, poseResult: nil)
            return
        }
        
        self.poseResult = poseLandmarkerResult // Keep for drawing
        
        storeResult(timestamp: timestampInMilliseconds, poseResult: poseLandmarkerResult)
    }
    
    func faceLandmarkerService(_ faceLandmarkerService: FaceLandmarkerService, didFinishDetection result: FaceResultBundle?, timestampInMilliseconds: Int, error: Error?) {
        guard let result = result, let faceLandmarkerResult = result.faceLandmarkerResults.first as? FaceLandmarkerResult else {
            DispatchQueue.main.async { self.clearFaceLandmarks() }
            storeResult(timestamp: timestampInMilliseconds, faceResult: nil)
            return
        }
        
        self.faceResult = faceLandmarkerResult // Keep for drawing
        
        storeResult(timestamp: timestampInMilliseconds, faceResult: faceLandmarkerResult)
    }
    
    // --- Aggregation and Processing Logic ---

    // Stores a result component in the aggregator for a given timestamp
    private func storeResult(timestamp: Int, handResult: HandLandmarkerResult? = nil, poseResult: PoseLandmarkerResult? = nil, faceResult: FaceLandmarkerResult? = nil) {
        guard timestamp != -1 else { return } // Ignore invalid timestamps

        resultsAggregatorQueue.async { [weak self] in
            guard let self = self else { return }

            // Get or create the entry for this timestamp
            var entry = self.resultsAggregator[timestamp] ?? AggregatedResults()

            // Update the entry with the new result component
            if let hand = handResult { entry.handResult = hand }
            if let pose = poseResult { entry.poseResult = pose }
            if let face = faceResult { entry.faceResult = face }

            // Store the updated entry back
            self.resultsAggregator[timestamp] = entry

            // Check if this timestamp is now complete
            self.checkAndProcessResults(timestamp: timestamp)
        }
    }

    // Checks if all results for a timestamp are available and processes them
    private func checkAndProcessResults(timestamp: Int) {
        // This function is already called within the resultsAggregatorQueue

        guard let entry = self.resultsAggregator[timestamp] else { return }

        // Check if all three result types have been received for this timestamp
        // Note: A result being present doesn't mean landmarks were detected, just that the service finished.
        if entry.handResult != nil && entry.poseResult != nil && entry.faceResult != nil {
            // All results received, process them
            print("✅ Synchronized results received for timestamp: \(timestamp)")
            self.processSynchronizedResults(
                handResult: entry.handResult,
                poseResult: entry.poseResult,
                faceResult: entry.faceResult
            )

            // Remove the processed entry from the aggregator
            self.resultsAggregator.removeValue(forKey: timestamp)

            // Optional: Clean up old entries if the aggregator grows too large
            self.cleanupAggregator()
        }
    }

    // Processes the synchronized results for a single frame/timestamp
    private func processSynchronizedResults(handResult: HandLandmarkerResult?, poseResult: PoseLandmarkerResult?, faceResult: FaceLandmarkerResult?) {
        // This function is called from the resultsAggregatorQueue

        guard isViewActive else { return } // Ensure view is still active

        do {
            // Extract holistic keypoints using the synchronized results
            let (keypoints, nonZeroCount) = try extractHolisticKeypoints(handResult: handResult, poseResult: poseResult, faceResult: faceResult)
            
            // --- Quality Check ---
            guard nonZeroCount >= keypointQualityThreshold else {
                print("⚠️ Frame quality low (\(nonZeroCount) < \(keypointQualityThreshold) non-zero keypoints). Clearing sequence buffer.")
                // Clear buffer on the correct queue
                sequenceBufferQueue.async { [weak self] in
                    self?.sequenceBuffer.removeAll()
                }
                // Optionally update UI to indicate poor tracking
                DispatchQueue.main.async {
                    PredictionViewModel.shared.setPrediction("Poor tracking...")
                }
                return // Do not add this low-quality frame to the buffer
            }
            // --- End Quality Check ---
 
            // Use the sequence buffer queue for buffer access
            sequenceBufferQueue.async { [weak self] in
                guard let self = self else { return }

                // Add to sequence buffer
                self.sequenceBuffer.append(keypoints)

                // Keep only the last 'sequenceLength' frames
                if self.sequenceBuffer.count > self.sequenceLength {
                    self.sequenceBuffer.removeFirst()
                }

                // Only make a prediction when we have a full sequence
                if self.sequenceBuffer.count == self.sequenceLength {
                    // Copy the buffer to prevent race conditions during prediction
                    let bufferCopy = self.sequenceBuffer

                    // Perform prediction on a background queue
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.predictFromSequence(with: bufferCopy)
                    }
                }
            }
        } catch {
            print("Error extracting holistic keypoints from synchronized results: \(error)")
        }
    }

    // Optional: Periodically clean up old entries from the aggregator
    private func cleanupAggregator() {
        // Example: Remove entries older than 1 second
        let cutoffTimestamp = Int(Date().timeIntervalSince1970 * 1000) - 1000
        let keysToRemove = resultsAggregator.keys.filter { $0 < cutoffTimestamp }
        for key in keysToRemove {
            resultsAggregator.removeValue(forKey: key)
        }
        if !keysToRemove.isEmpty {
             print("🧹 Cleaned up \(keysToRemove.count) old entries from aggregator.")
        }
    }

    // --- Landmark Drawing (Unchanged, but clear functions added) ---
    // ... existing processHandLandmarks, drawHandLandmarks, drawHandConnections ...
    func clearHandLandmarks() {
        DispatchQueue.main.async {
            if let sublayers = self.view.layer.sublayers {
                for layer in sublayers {
                    if layer.name == "handLandmarksLayer" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
    // ... existing processPoseLandmarks, drawPoseLandmarks, drawPoseConnections ...
    func clearPoseLandmarks() {
        DispatchQueue.main.async {
            if let sublayers = self.view.layer.sublayers {
                for layer in sublayers {
                    if layer.name == "poseLandmarksLayer" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
    // ... existing processFaceLandmarks, drawFaceLandmarks, drawFaceOutline ...
    func clearFaceLandmarks() {
        DispatchQueue.main.async {
            if let sublayers = self.view.layer.sublayers {
                for layer in sublayers {
                    if layer.name == "faceLandmarksLayer" {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }

    // --- Holistic Keypoint Extraction & Prediction ---

    // Modified to accept specific results and return nonZeroCount
    func extractHolisticKeypoints(handResult: HandLandmarkerResult?, poseResult: PoseLandmarkerResult?, faceResult: FaceLandmarkerResult?) throws -> (MLMultiArray, Int) {
        // ... (rest of the function remains the same, using the passed-in results)
        let shape = [NSNumber(value: 1662)]
        let holisticArray = try MLMultiArray(shape: shape, dataType: .float32)

        var nonZeroCount = 0 // Track non-zero entries
        var currentIndex = 0

        // Extract pose landmarks (33 landmarks * 4 values)
        if let poseLandmarks = poseResult?.landmarks.first { // Use passed-in poseResult
            let poseCount = min(33, poseLandmarks.count)
            for i in 0..<poseCount {
                let landmark = poseLandmarks[i]
                if currentIndex + 3 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                    // Visibility check is part of pose, not counted here for consistency
                    if landmark.x != 0 || landmark.y != 0 || landmark.z != 0 { nonZeroCount += 3 }
                }
                currentIndex += 4 // Pose includes visibility
            }
            // Fill remaining pose slots if fewer than 33 landmarks detected
            let remainingPoseSlots = (33 * 4) - (poseCount * 4)
             for _ in 0..<remainingPoseSlots {
                 if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                 currentIndex += 1
             }
        } else {
            // Fill with zeros if no pose data
            let poseValues = 132
            for _ in 0..<poseValues {
                if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                currentIndex += 1
            }
        }

        // Extract face landmarks (468 landmarks * 3 values)
        if let faceLandmarks = faceResult?.faceLandmarks.first { // Use passed-in faceResult
            let faceCount = min(468, faceLandmarks.count)
            for i in 0..<faceCount {
                let landmark = faceLandmarks[i]
                if currentIndex + 2 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                    if landmark.x != 0 || landmark.y != 0 || landmark.z != 0 { nonZeroCount += 3 }
                }
                currentIndex += 3
            }
             // Fill remaining face slots if fewer than 468 landmarks detected
             let remainingFaceSlots = (468 * 3) - (faceCount * 3)
             for _ in 0..<remainingFaceSlots {
                 if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                 currentIndex += 1
             }
        } else {
            // Fill with zeros if no face data
            let faceValues = 1404
            for _ in 0..<faceValues {
                if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                currentIndex += 1
            }
        }

        // Extract left hand landmarks (21 landmarks * 3 values)
        // Check handedness if available, otherwise assume first is left
        var leftHandLandmarks: [NormalizedLandmark]?
        var rightHandLandmarks: [NormalizedLandmark]?

        if let hands = handResult?.landmarks, let handedness = handResult?.handedness {
            for i in 0..<min(hands.count, handedness.count) {
                if handedness[i].first?.categoryName == "Left" {
                    leftHandLandmarks = hands[i]
                } else if handedness[i].first?.categoryName == "Right" {
                    rightHandLandmarks = hands[i]
                }
            }
            // Fallback if handedness doesn't match or only one hand detected
            if leftHandLandmarks == nil && rightHandLandmarks == nil && !hands.isEmpty {
                 if hands.count == 1 && handedness.first?.first?.categoryName == "Right" {
                     rightHandLandmarks = hands[0] // Only right detected
                 } else {
                     leftHandLandmarks = hands[0] // Assume left if unknown or only one detected as Left
                     if hands.count > 1 && rightHandLandmarks == nil {
                         rightHandLandmarks = hands[1] // Assume second is right if not assigned
                     }
                 }
            }
        } else if let hands = handResult?.landmarks, !hands.isEmpty {
            // Fallback if no handedness info
            leftHandLandmarks = hands.first
            if hands.count > 1 {
                rightHandLandmarks = hands[1]
            }
        }


        // --- Logging for "iloveyou" ---
        if targetSign.lowercased() == "iloveyou" {
            let leftHandDetected = leftHandLandmarks != nil && !leftHandLandmarks!.isEmpty
            let rightHandDetected = rightHandLandmarks != nil && !rightHandLandmarks!.isEmpty
            print("💜 ILOVEYOU Check: Left Hand: \(leftHandDetected), Right Hand: \(rightHandDetected)")
        }

        if let leftHand = leftHandLandmarks { // Use identified left hand
            let leftHandCount = min(21, leftHand.count)
            for i in 0..<leftHandCount {
                let landmark = leftHand[i]
                if currentIndex + 2 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                    if landmark.x != 0 || landmark.y != 0 || landmark.z != 0 { nonZeroCount += 3 }
                }
                currentIndex += 3
            }
             // Fill remaining left hand slots
             let remainingLHandSlots = (21 * 3) - (leftHandCount * 3)
             for _ in 0..<remainingLHandSlots {
                 if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                 currentIndex += 1
             }
        } else {
            // Fill with zeros if no left hand data
            let leftHandValues = 63
            for _ in 0..<leftHandValues {
                if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                currentIndex += 1
            }
        }

        // Extract right hand landmarks (21 landmarks * 3 values)
        if let rightHand = rightHandLandmarks { // Use identified right hand
            let rightHandCount = min(21, rightHand.count)
            for i in 0..<rightHandCount {
                let landmark = rightHand[i]
                if currentIndex + 2 < 1662 {
                    holisticArray[currentIndex] = NSNumber(value: landmark.x)
                    holisticArray[currentIndex + 1] = NSNumber(value: landmark.y)
                    holisticArray[currentIndex + 2] = NSNumber(value: landmark.z)
                    if landmark.x != 0 || landmark.y != 0 || landmark.z != 0 { nonZeroCount += 3 }
                }
                currentIndex += 3
            }
             // Fill remaining right hand slots
             let remainingRHandSlots = (21 * 3) - (rightHandCount * 3)
             for _ in 0..<remainingRHandSlots {
                 if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                 currentIndex += 1
             }
        } else {
            // Fill with zeros if no right hand data
            let rightHandValues = 63
            for _ in 0..<rightHandValues {
                if currentIndex < 1662 { holisticArray[currentIndex] = 0.0 }
                currentIndex += 1
            }
        }

        // Final check for array size consistency
         if currentIndex != 1662 {
             print("⚠️ Warning: Final keypoint array size is \(currentIndex), expected 1662. Filling remaining with zeros.")
             while currentIndex < 1662 {
                 holisticArray[currentIndex] = 0.0
                 currentIndex += 1
             }
         }

        // Log the number of non-zero keypoints extracted for this frame
        print("📊 Extracted Keypoints: \(nonZeroCount) non-zero values out of 1662.")

        return (holisticArray, nonZeroCount)
    }

    // Predict using sequence of holistic keypoints (No change needed here)
    func predictFromSequence(with sequenceBuffer: [MLMultiArray]) {
        do {
            // Safety check
            guard sequenceBuffer.count == sequenceLength else {
                print("⚠️ Sequence buffer length mismatch: \(sequenceBuffer.count) vs expected \(sequenceLength)")
                return
            }
            
            let config = MLModelConfiguration()
            
            // Use the holistic model
            let model = try ASLClassifierHolistic(configuration: config)
            
            // Create a combined multi-array for the sequence [1, 30, 1662]
            let sequenceShape = [NSNumber(value: 1), NSNumber(value: 30), NSNumber(value: 1662)]
            let sequenceMultiArray = try MLMultiArray(shape: sequenceShape, dataType: .float32)

            // --- Log Input Quality ---
            var totalNonZerosInSequence = 0
            
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
                        let value = frame[keypointIndex]
                        sequenceMultiArray[[0, frameIndex, keypointIndex] as [NSNumber]] = value
                        if value.floatValue != 0.0 {
                            totalNonZerosInSequence += 1
                        }
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

            // Log how many non-zero values were in the sequence fed to the model
            print("📉 Input Sequence Quality: \(totalNonZerosInSequence) non-zero values in the 30-frame sequence.")
            
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
