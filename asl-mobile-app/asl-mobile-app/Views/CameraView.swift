import SwiftUI
import AVFoundation
import MediaPipeTasksVision

struct HandTrackingView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // Camera preview layer
            CameraPreviewView(session: cameraManager.session)
                .edgesIgnoringSafeArea(.all)
            
            // Hand landmark overlay
//            HandOverlayView(
//                handOverlays: cameraManager.handOverlays,
//                imageSize: cameraManager.captureDeviceResolution
//            )
            
            // Camera status indicator
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
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .padding()
            }
        }
        .onAppear {
            cameraManager.checkPermissionsAndStartSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .alert(isPresented: $cameraManager.showPermissionAlert) {
            Alert(
                title: Text("Camera Permission Required"),
                message: Text("This app needs camera access to detect hand landmarks."),
                primaryButton: .default(Text("Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

// Camera preview using UIViewRepresentable
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// Camera manager that handles AVCapture and MediaPipe integration
class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, HandLandmarkerServiceLiveStreamDelegate {
    
    let session = AVCaptureSession()
    private var handLandmarker: HandLandmarkerService?
    private let cameraQueue = DispatchQueue(label: "com.app.cameraQueue")
    
    @Published var isSessionInterrupted = false
    @Published var showPermissionAlert = false
    @Published var handOverlays: [HandOverlay] = []
    @Published var captureDeviceResolution: CGSize = CGSize(width: 1280, height: 720)
    
    override init() {
        super.init()
        setupCamera()
//        setupHandLandmarker()
        
        // Monitor session interruptions
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(sessionWasInterrupted),
//            name: .AVCaptureSessionWasInterrupted,
//            object: session
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(sessionInterruptionEnded),
//            name: .AVCaptureSessionInterruptionEnded,
//            object: session
//        )
    }
    
    func checkPermissionsAndStartSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startSession()
                    } else {
                        self?.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: cameraQueue)
        output.alwaysDiscardsLateVideoFrames = true
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        if let connection = output.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = true
        }
        
        // Update capture device resolution based on the active format
        let device = camera.activeFormat.formatDescription
        let dimensions = CMVideoFormatDescriptionGetDimensions(device)
        captureDeviceResolution = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
        
        
        session.commitConfiguration()
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
        cameraQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopSession() {
        cameraQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func resumeSession() {
        isSessionInterrupted = false
        startSession()
    }
    
    @objc private func sessionWasInterrupted(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.isSessionInterrupted = true
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.isSessionInterrupted = false
        }
    }
    
    func handLandmarkerService(_ handLandmarkerService: HandLandmarkerService, didFinishDetection result: ResultBundle?, error: (any Error)?) {
        guard let result = result else {
            return
        }
        
        processHandLandmarks(result.handLandmarkerResults)
    }
    
    // Convert MediaPipe hand landmarks to HandOverlay objects
    private func processHandLandmarks(_ results: [HandLandmarkerResult?]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var overlays: [HandOverlay] = []
            
            for result in results {
                // Process each hand landmark result\
                if let handLandmarkerResult = result {
                    for handLandmarks in handLandmarkerResult.landmarks {
                        var dots: [CGPoint] = []
                        var lines: [Line] = []
                        
                        // Convert landmarks to points
                        dots = handLandmarks.map { landmark in
                            // Convert MediaPipe coordinates to UI coordinates
                            // MediaPipe uses [0,1] with (0,0) at top-left
                            return CGPoint(x: CGFloat(landmark.x), y: CGFloat(landmark.y))
                        }
                        
                        // Define connections between landmarks for hand skeleton
                        // These indices are based on MediaPipe hand landmark model
                        let connections: [(Int, Int)] = [
                            // Thumb
                            (0, 1), (1, 2), (2, 3), (3, 4),
                            // Index finger
                            (0, 5), (5, 6), (6, 7), (7, 8),
                            // Middle finger
                            (0, 9), (9, 10), (10, 11), (11, 12),
                            // Ring finger
                            (0, 13), (13, 14), (14, 15), (15, 16),
                            // Little finger
                            (0, 17), (17, 18), (18, 19), (19, 20),
                            // Palm
                            (0, 5), (5, 9), (9, 13), (13, 17)
                        ]
                        
                        // Create lines based on connections
                        for (start, end) in connections {
                            guard start < dots.count && end < dots.count else { continue }
                            lines.append(Line(from: dots[start], to: dots[end]))
                        }
                        
                        overlays.append(HandOverlay(dots: dots, lines: lines))
                    }
                }
            }
            
            self.handOverlays = overlays
        }
    }
}
