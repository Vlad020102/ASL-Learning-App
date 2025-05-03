import Foundation
import AVFoundation
import MediaPipeTasksVision
import CoreML
import UIKit // Needed for UIImage.Orientation

// Structure to hold a single training/testing sample
struct TrainingDataSample {
    let features: MLMultiArray // The [1, 42] input
    let label: String          // The ground truth label (e.g., "Please")
}

@MainActor
class TrainingDataCollector: NSObject, ObservableObject, HandLandmarkerServiceLiveStreamDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    @Published var isCollecting: Bool = false
    @Published var collectionProgress: Double = 0.0 // 0.0 to 1.0
    @Published var status: String = "Idle"

    private var handLandmarkerService: HandLandmarkerService?
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "TrainingDataCollectorSessionQueue", qos: .userInitiated)
    private var videoOutput = AVCaptureVideoDataOutput()

    private var collectedSamples: [TrainingDataSample] = []
    private var targetLabel: String = ""
    private var collectionStartTime: Date?
    private var collectionDuration: TimeInterval = 0
    private var completionHandler: (([TrainingDataSample]) -> Void)?
    private var progressTimer: Timer?

    override init() {
        super.init()
        setupHandLandmarker()
    }

    // MARK: - Setup
    private func setupHandLandmarker() {
        status = "Initializing Hand Landmarker..."
        let modelPath = Bundle.main.path(forResource: DefaultConstants.handLandmarkerModelPath, ofType: "task")
        // Using CPU delegate for background processing stability
        guard let delegate = HandLandmarkerDelegate(name: "CPU") else {
             print("Error: Could not create HandLandmarkerDelegate")
             status = "Error: Failed to create landmarker delegate."
             return
        }

        handLandmarkerService = HandLandmarkerService.liveStreamHandLandmarkerService(
            modelPath: modelPath,
            numHands: 1, // Collect data for one hand at a time for simplicity
            minHandDetectionConfidence: 0.3,
            minHandPresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
            liveStreamDelegate: self,
            delegate: delegate
        )
        if handLandmarkerService == nil {
            status = "Error: Failed to initialize HandLandmarkerService."
            print(status)
        } else {
             status = "Hand Landmarker Initialized."
             print(status)
        }
    }

    private func setupCaptureSession() -> Bool {
        status = "Setting up camera..."
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480 // Lower resolution might be sufficient and faster

        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Error: Could not find front camera.")
            status = "Error: Front camera not found."
            captureSession.commitConfiguration()
            return false
        }
        do {
            // Remove existing inputs
             if let currentInput = captureSession.inputs.first {
                 captureSession.removeInput(currentInput)
             }
            let input = try AVCaptureDeviceInput(device: videoDevice)
            guard captureSession.canAddInput(input) else {
                print("Error: Could not add camera input.")
                status = "Error: Cannot add camera input."
                captureSession.commitConfiguration()
                return false
            }
            captureSession.addInput(input)
        } catch {
            print("Error creating camera input: \(error)")
            status = "Error: Failed to create camera input."
            captureSession.commitConfiguration()
            return false
        }

        // Video output
        if captureSession.outputs.contains(videoOutput) {
             captureSession.removeOutput(videoOutput)
        }
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue) // Process on background queue
        videoOutput.alwaysDiscardsLateVideoFrames = true // Important for real-time

        guard captureSession.canAddOutput(videoOutput) else {
            print("Error: Could not add video output.")
            status = "Error: Cannot add video output."
            captureSession.commitConfiguration()
            return false
        }
        captureSession.addOutput(videoOutput)

        // Set orientation
        videoOutput.connection(with: .video)?.videoOrientation = .portrait

        captureSession.commitConfiguration()
        status = "Camera setup complete."
        print(status)
        return true
    }

    // MARK: - Data Collection Control
    func startCollection(label: String, duration: TimeInterval, completion: @escaping ([TrainingDataSample]) -> Void) {
        guard !isCollecting else {
            print("Collection already in progress.")
            return
        }
        guard handLandmarkerService != nil else {
             status = "Error: Hand Landmarker not ready."
             print(status)
             completion([]) // Return empty if service isn't ready
             return
        }

        checkCameraPermission { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.status = "Error: Camera permission denied."
                print(self.status)
                completion([])
                return
            }

            // Setup session on the dedicated queue
            self.sessionQueue.async {
                guard self.setupCaptureSession() else {
                    DispatchQueue.main.async {
                        completion([]) // Return empty if setup fails
                    }
                    return
                }

                // Start session and collection state on main thread
                DispatchQueue.main.async {
                    self.targetLabel = label
                    self.collectionDuration = duration
                    self.collectedSamples = []
                    self.completionHandler = completion
                    self.collectionStartTime = Date()
                    self.isCollecting = true
                    self.status = "Collecting data for '\(label)'..."
                    print(self.status)

                    self.captureSession.startRunning()

                    // Start progress timer
                    self.collectionProgress = 0.0
                    self.progressTimer?.invalidate()
                    self.progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                        self?.updateProgress()
                    }

                    // Schedule stop
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                        self?.stopCollection()
                    }
                }
            }
        }
    }

    private func stopCollection() {
        guard isCollecting else { return }

        progressTimer?.invalidate()
        progressTimer = nil
        collectionProgress = 1.0 // Ensure it reaches 100%
        isCollecting = false
        status = "Collection finished. Processing..."
        print("Stopping capture session...")

        sessionQueue.async { [weak self] in
             guard let self = self else { return }
             if self.captureSession.isRunning {
                 self.captureSession.stopRunning()
                 print("Capture session stopped.")
             }

             // Clean up inputs/outputs after stopping
             if let currentInput = self.captureSession.inputs.first {
                 self.captureSession.removeInput(currentInput)
             }
             if self.captureSession.outputs.contains(self.videoOutput) {
                 self.captureSession.removeOutput(self.videoOutput)
             }
             print("Capture session inputs/outputs removed.")


             // Call completion handler on main thread with collected data
             let samplesToReturn = self.collectedSamples
             DispatchQueue.main.async {
                 print("Collected \(samplesToReturn.count) valid samples.")
                 self.status = "Idle. Collected \(samplesToReturn.count) samples."
                 self.completionHandler?(samplesToReturn)
                 // Clear state
                 self.completionHandler = nil
                 self.collectedSamples = []
                 self.collectionStartTime = nil
             }
        }
    }

    private func updateProgress() {
        guard let startTime = collectionStartTime, collectionDuration > 0 else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        collectionProgress = min(max(0.0, elapsed / collectionDuration), 1.0)
        status = "Collecting... (\(Int(collectionProgress * 100))%)"
    }


    // MARK: - Camera Permission
     private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
         switch AVCaptureDevice.authorizationStatus(for: .video) {
         case .authorized:
             completion(true)
         case .notDetermined:
             AVCaptureDevice.requestAccess(for: .video) { granted in
                 DispatchQueue.main.async {
                     completion(granted)
                 }
             }
         default:
             completion(false)
         }
     }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isCollecting else { return } // Only process if collecting

        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        // Use the existing handLandmarkerService instance
        handLandmarkerService?.detectAsync(
            sampleBuffer: sampleBuffer,
            orientation: .up, // Assuming portrait front camera
            timeStamps: timestamp
        )
    }

    // MARK: - HandLandmarkerServiceLiveStreamDelegate
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, didFinishDetection result: HandResultBundle?, timestampInMilliseconds: Int, error: Error?) {
        guard isCollecting else { return } // Ensure we are still in collection mode
        guard error == nil else {
            print("Hand Landmarker Error: \(error!.localizedDescription)")
            return
        }
        guard let handLandmarkerResult = result?.handLandmarkerResults.first as? HandLandmarkerResult,
              !handLandmarkerResult.landmarks.isEmpty else {
            // No hand detected in this frame, skip
            // print("No hand detected for timestamp \(timestampInMilliseconds)")
            return
        }

        // Convert landmarks to MLMultiArray
        do {
            // Use the conversion logic (ensure it handles the [1, 42] shape)
            if let multiArray = try convertHandLandmarksToMLMultiArray(results: handLandmarkerResult) {
                 // Append the valid sample
                 let sample = TrainingDataSample(features: multiArray, label: targetLabel)
                 // Since this delegate might be called from a background thread MediaPipe uses,
                 // ensure thread safety if appending to the array directly.
                 // Or, collect on a background queue and process at the end.
                 // For simplicity here, dispatching append to main actor's context.
                 DispatchQueue.main.async { [weak self] in
                      guard let self = self, self.isCollecting else { return } // Check again if still collecting
                      self.collectedSamples.append(sample)
                 }
            } else {
                 // print("Frame skipped: Could not convert landmarks.")
            }
        } catch {
            print("Error converting landmarks: \(error)")
        }
    }

    // MARK: - Landmark Conversion (Adapted from SimpleCameraViewController)
    // Returns nil if no valid landmarks found or conversion fails
    private func convertHandLandmarksToMLMultiArray(results: HandLandmarkerResult?) throws -> MLMultiArray? {
         // Expecting results for exactly one hand (as configured in setupHandLandmarker)
         guard let handLandmarks = results?.landmarks.first, !handLandmarks.isEmpty else {
             // print("No landmarks found in result.")
             return nil // Indicate no valid data for this frame
         }

         // Ensure we have the expected number of landmarks (21 for MediaPipe Hand)
         guard handLandmarks.count == 21 else {
              print("Warning: Unexpected number of landmarks found: \(handLandmarks.count)")
              return nil
         }

         var dataAux: [Float] = []
         var minX = Float.greatestFiniteMagnitude
         var minY = Float.greatestFiniteMagnitude

         // First pass: find min X and Y for normalization relative to the hand
         for landmark in handLandmarks {
             minX = min(minX, landmark.x)
             minY = min(minY, landmark.y)
         }

         // Second pass: calculate normalized coordinates and flatten
         for landmark in handLandmarks {
             dataAux.append(landmark.x - minX)
             dataAux.append(landmark.y - minY)
             // Ignore Z for now to match the [42] shape
         }

         // Ensure we have exactly 42 values (21 landmarks * 2 coordinates)
         guard dataAux.count == 42 else {
             print("Error: Flattened data count is \(dataAux.count), expected 42.")
             return nil
         }

         // Create MLMultiArray of shape [1, 42] as expected by many models
         // Or shape [42] if the model expects a flat vector. Adjust as needed.
         // Assuming ASLClassifier expects [42] based on SimpleCameraViewController
         let multiArray = try MLMultiArray(shape: [NSNumber(value: 42)], dataType: .float32) // Or .double

         for i in 0..<dataAux.count {
             multiArray[i] = NSNumber(value: dataAux[i])
         }

         return multiArray
     }
}

// Helper Delegate class (can be minimal if only used for CPU/GPU selection)
class HandLandmarkerDelegate: NSObject, CoreMLDelegate {
    var delegate: CoreMLDelegate.Delegate = .cpu // Default to CPU

    init?(name: String) {
        if name.lowercased() == "gpu" {
            self.delegate = .gpu
        } else {
            self.delegate = .cpu
        }
    }
}
