import SwiftUI
import AVFoundation
import MediaPipeTasksVision

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var showPermissionAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)

            if cameraManager.isSessionInterrupted {
                VStack {
                    Text("Camera Unavailable")
                        .font(.title)
                        .foregroundColor(.white)
                    Button("Resume") {
                        cameraManager.resumeSession()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            HandOverlayView(handOverlays: convertToHandOverlay(from: cameraManager.handLandmarks))
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Camera Permissions Denied"),
                message: Text("Enable camera access in Settings."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func convertToHandOverlay(from results: [HandLandmarkerResult]) -> [HandOverlay] {
        var overlays: [HandOverlay] = []

        for result in results {
            var dots: [CGPoint] = []
            var lines: [Line] = []
            
            // Assuming result has a method to get landmarks
            let landmarks = result.landmarks // Adjust based on actual structure

            // Loop through the landmarks and create dots
            for landmark in landmarks {
                dots = landmark.map({CGPoint(x: CGFloat($0.y), y: 1 - CGFloat($0.x))})
            }

            // Define the connections between landmarks for lines
            let connections: [(Int, Int)] = [
                (0, 1), (1, 2), (2, 3), // Example for fingers, adjust indices accordingly
                (0, 4), // Connect thumb to palm
                // Add more connections based on the landmark structure
            ]

            // Create lines based on connections
            for connection in connections {
                guard connection.0 < dots.count && connection.1 < dots.count else { continue }
                let startPoint = dots[connection.0]
                let endPoint = dots[connection.1]
                let line = Line(from: startPoint, to: endPoint)
                lines.append(line)
            }

            // Create a HandOverlay for this result and add it to the array
            let overlay = HandOverlay(dots: dots, lines: lines)
            overlays.append(overlay)
        }

        return overlays
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var isSessionInterrupted = false
    @Published var handLandmarks: [HandLandmarkerResult] = []
    
    private let cameraQueue = DispatchQueue(label: "cameraQueue")
    private var handLandmarker: HandLandmarkerService?
    
    override init() {
        super.init()
        setupCamera()
        setupHandLandmarker()
    }
    
    func setupCamera() {
        session.sessionPreset = .high
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: cameraQueue)
        
        if session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
        }
    }
    
    func setupHandLandmarker() {
        handLandmarker = HandLandmarkerService.liveStreamHandLandmarkerService(
            modelPath: InferenceConfigurationManager.sharedInstance.modelPath,
            numHands: InferenceConfigurationManager.sharedInstance.numHands,
            minHandDetectionConfidence: InferenceConfigurationManager.sharedInstance.minHandDetectionConfidence,
            minHandPresenceConfidence: InferenceConfigurationManager.sharedInstance.minHandPresenceConfidence,
            minTrackingConfidence: InferenceConfigurationManager.sharedInstance.minTrackingConfidence,
            liveStreamDelegate: self,
            delegate: InferenceConfigurationManager.sharedInstance.delegate
        )
    }
    
    func startSession() {
        cameraQueue.async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        cameraQueue.async {
            self.session.stopRunning()
        }
    }
    
    func resumeSession() {
        isSessionInterrupted = false
        startSession()
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        handLandmarker?.detectAsync(sampleBuffer: sampleBuffer, orientation: .up, timeStamps: Int(currentTimeMs))
    }
}

extension CameraManager: HandLandmarkerServiceLiveStreamDelegate {
    func handLandmarkerService(_ service: HandLandmarkerService, didFinishDetection result: ResultBundle?, error: Error?) {
        DispatchQueue.main.async {
            if let result = result?.handLandmarkerResults.first as? HandLandmarkerResult {
                self.handLandmarks = [result]
            }
        }
    }
}

struct CameraManagerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPreview(session: AVCaptureSession())
    }
}
