//import Foundation
//import CoreML
//import Combine // For status updates
//import MediaPipeTasksVision // Needed for HandLandmarkerResult used by collector
//
//// !!! Removed HandLandmarkDataSource protocol and SimulatedHandLandmarkDataSource !!!
//
//// !!! Placeholder: Define this struct based on your actual HandLandmarkerService output !!!
//// This is now defined in TrainingDataCollector.swift, but kept here for reference in BatchProvider/Client
//// struct TrainingDataSample {
////     let features: MLMultiArray // The [1, 42] input
////     let label: String          // The ground truth label (e.g., "Please")
//// }
//
//
//// Helper to create MLBatchProvider for Core ML training
//class LandmarkBatchProvider: MLBatchProvider {
//    // !!! Updated to use TrainingDataSample !!!
//    let trainingData: [TrainingDataSample]
//    let inputFeatureName: String // Name of the input feature in your Core ML model
//    let outputFeatureName: String // Name of the output (target) feature in your Core ML model
//
//    var count: Int {
//        return trainingData.count
//    }
//
//    init(trainingData: [TrainingDataSample], inputFeatureName: String, outputFeatureName: String) {
//        self.trainingData = trainingData
//        self.inputFeatureName = inputFeatureName
//        self.outputFeatureName = outputFeatureName
//    }
//
//    func features(at index: Int) -> MLFeatureProvider {
//        let sample = trainingData[index]
//        // !!! Important: Adapt this based on your model's expected output format for training !!!
//        // This assumes the model's training output is a String label.
//        // If it expects a different format (e.g., one-hot encoded vector), adjust this.
//        let outputValue = MLFeatureValue(string: sample.label)
//
//        let featureValues: [String: MLFeatureValue] = [
//            inputFeatureName: MLFeatureValue(multiArray: sample.features),
//            outputFeatureName: outputValue
//        ]
//        // Use try! assuming conversion is always valid based on TrainingDataCollector logic
//        return try! MLDictionaryFeatureProvider(dictionary: featureValues)
//    }
//}
//
//
//@MainActor
//class FederatedLearningManager: ObservableObject {
//    @Published var status: String = "Idle"
//    @Published var isRunning: Bool = false
//    @Published var collectorStatus: String = "Idle"
//    @Published var collectorProgress: Double = 0.0
//    @Published var isCollectingData: Bool = false
//
//    private var flowerService: FlowerService?
//    private var coreMLModel: MLModel?
//    private var updatableModelURL: URL? // URL to the updatable model file in app's support directory
//    private let serverURL = "localhost:8080" // Replace with your actual server address if different
//    private let modelAssetName = "ASLClassifier" // Base name of your model asset
//    private let modelExtension = "mlmodelc" // Compiled model extension
//
//    // !!! Important: Replace with the actual input/output names from your Core ML model !!!
//    private let modelInputName = "input_1" // Check your model's input layer name
//    private let modelOutputName = "Identity" // Check your model's output layer name (often 'Identity' or similar)
//    private let modelTargetName = "target" // Check the name expected for the target label during training
//
//    // !!! Use TrainingDataCollector instead of DataSource !!!
//    private let trainingDataCollector = TrainingDataCollector()
//    private var collectorCancellable: AnyCancellable?
//    private var collectorProgressCancellable: AnyCancellable?
//    private var collectorStatusCancellable: AnyCancellable?
//
//
//    init() {
//        setupModel()
//        // Observe the collector's state
//        collectorCancellable = trainingDataCollector.$isCollecting
//            .receive(on: RunLoop.main)
//            .sink { [weak self] collecting in
//                self?.isCollectingData = collecting
//            }
//        collectorProgressCancellable = trainingDataCollector.$collectionProgress
//             .receive(on: RunLoop.main)
//             .sink { [weak self] progress in
//                 self?.collectorProgress = progress
//             }
//         collectorStatusCancellable = trainingDataCollector.$status
//              .receive(on: RunLoop.main)
//              .sink { [weak self] status in
//                  self?.collectorStatus = status
//              }
//    }
//
//    private func setupModel() {
//        guard let assetURL = Bundle.main.url(forResource: modelAssetName, withExtension: modelExtension) else {
//            status = "Error: Compiled Core ML model (\(modelAssetName).\(modelExtension)) not found in bundle."
//            print(status)
//            return
//        }
//
//        // Copy the model to a writable location (Application Support) to allow updates
//        let fileManager = FileManager.default
//        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
//            status = "Error: Cannot access Application Support directory."
//            print(status)
//            return
//        }
//
//        let destinationURL = appSupportURL.appendingPathComponent("\(modelAssetName)_updatable.\(modelExtension)")
//        self.updatableModelURL = destinationURL
//
//        do {
//            // Remove existing model if it exists, to start fresh
//            if fileManager.fileExists(atPath: destinationURL.path) {
//                try fileManager.removeItem(at: destinationURL)
//            }
//            // Copy the bundled model to the writable location
//            try fileManager.copyItem(at: assetURL, to: destinationURL)
//            print("Copied model to writable location: \(destinationURL.path)")
//
//            // Load the model from the writable location
//            let config = MLModelConfiguration()
//            config.computeUnits = .all // Or .cpuAndGPU, .cpuOnly
//            self.coreMLModel = try MLModel(contentsOf: destinationURL, configuration: config)
//            status = "Model loaded successfully."
//            print(status)
//
//        } catch {
//            status = "Error setting up model: \(error.localizedDescription)"
//            print("\(status)\nError details: \(error)")
//            self.updatableModelURL = nil
//            self.coreMLModel = nil
//        }
//    }
//
//    func startFederatedLearning(label: String = "Please") {
//        guard !isRunning, !isCollectingData else {
//            print("Federated learning or data collection already in progress.")
//            status = isCollectingData ? "Waiting for data collection..." : "FL already running."
//            return
//        }
//        guard let model = coreMLModel, let modelURL = updatableModelURL else {
//            status = "Error: Model not loaded or not updatable."
//            print(status)
//            return
//        }
//        guard let server = URL(string: serverURL) else {
//             status = "Error: Invalid server URL."
//             print(status)
//             return
//        }
//
//        // Don't set isRunning = true yet, wait for data collection
//        status = "Starting data collection..."
//        print(status)
//
//        // 1. Collect Data using TrainingDataCollector
//        trainingDataCollector.startCollection(label: label, duration: 10.0) { [weak self] collectedData in
//            // This completion is called on the MainActor
//            guard let self = self else { return }
//
//            guard !collectedData.isEmpty else {
//                self.status = "Error: No data collected. Aborting FL round."
//                print(self.status)
//                // Ensure isRunning is false if collection failed before starting FL
//                self.isRunning = false
//                return
//            }
//
//            self.status = "Data collection complete. Starting Federated Learning..."
//            self.isRunning = true // Now we can set the FL running state
//            print(status)
//
//            // Proceed with FL using the collectedData
//            self.runFlowerSession(allData: collectedData, modelURL: modelURL, serverURL: server)
//        }
//    }
//
//    // Extracted Flower session logic
//    private func runFlowerSession(allData: [TrainingDataSample], modelURL: URL, serverURL: URL) {
//        // 2. Split Data (Simple 80/20 split)
//        let shuffledData = allData.shuffled()
//        let trainCount = Int(Double(shuffledData.count) * 0.8)
//        let trainData = Array(shuffledData.prefix(trainCount))
//        let testData = Array(shuffledData.suffix(shuffledData.count - trainCount))
//        print("Data split: \(trainData.count) train, \(testData.count) test samples.")
//
//        guard !trainData.isEmpty else {
//             status = "Error: Not enough data to train after split."
//             print(status)
//             isRunning = false
//             return
//        }
//
//        // 3. Create Flower Client
//        let flowerClient = FlowerClient(
//            modelURL: modelURL,
//            modelInputName: modelInputName,
//            modelOutputName: modelOutputName,
//            modelTargetName: modelTargetName,
//            trainData: trainData, // Pass TrainingDataSample array
//            testData: testData,   // Pass TrainingDataSample array
//            statusUpdateHandler: { [weak self] message in
//                // Ensure UI updates are on the main thread
//                DispatchQueue.main.async {
//                    self?.status = message
//                }
//            }
//        )
//
//        // 4. Start Flower Service
//        self.flowerService = FlowerService(flowerClient: flowerClient)
//        status = "Connecting to server: \(serverURL.absoluteString)..."
//        // Note: connect() runs indefinitely until disconnect() is called or an error occurs.
//        // It should be run in a background task.
//        Task.detached { [weak self] in
//             await self?.flowerService?.connect(serverURL: serverURL)
//             // This part is reached after disconnection or error
//             DispatchQueue.main.async {
//                 print("Flower service disconnected.")
//                 if self?.isRunning ?? false { // Check if it was manually stopped
//                     self?.status = "Disconnected from server."
//                 }
//                 self?.isRunning = false
//                 self?.flowerService = nil
//             }
//        }
//    }
//
//    func stopFederatedLearning() {
//        // If data collection is happening, stop it first.
//        if isCollectingData {
//             print("Stopping ongoing data collection...")
//             // Collector's stopCollection handles state updates and cleanup
//             // We don't have a direct stop method in the collector, it stops by timer
//             // or when FL manager calls stopFederatedLearning. We might need an explicit stop.
//             // For now, just log it. The FL part won't start if collection is aborted.
//             status = "Data collection cancelled."
//             // Reset FL state if it was waiting for data
//             if !isRunning {
//                 status = "Idle"
//             }
//        }
//
//        guard isRunning else { return }
//        status = "Disconnecting..."
//        print(status)
//        Task {
//             await flowerService?.disconnect()
//             // State update (isRunning=false, status="Idle") happens in the connect task completion block
//        }
//    }
//}
//
//
//// MARK: - Flower Client Implementation
//
//class FlowerClient: Client {
//    let modelURL: URL
//    let modelInputName: String
//    let modelOutputName: String
//    let modelTargetName: String
//    // !!! Updated to use TrainingDataSample !!!
//    let trainData: [TrainingDataSample]
//    let testData: [TrainingDataSample]
//    let statusUpdateHandler: (String) -> Void
//    var currentModelParameters: [Data]? // Store parameters locally
//
//    init(modelURL: URL, modelInputName: String, modelOutputName: String, modelTargetName: String, trainData: [TrainingDataSample], testData: [TrainingDataSample], statusUpdateHandler: @escaping (String) -> Void) {
//        self.modelURL = modelURL
//        self.modelInputName = modelInputName
//        self.modelOutputName = modelOutputName
//        self.modelTargetName = modelTargetName
//        self.trainData = trainData
//        self.testData = testData
//        self.statusUpdateHandler = statusUpdateHandler
//        // Load initial parameters
//        self.currentModelParameters = loadParametersFromModel()
//    }
//
//    // Load parameters directly from the Core ML model file layers
//    private func loadParametersFromModel() -> [Data]? {
//         statusUpdateHandler("Loading initial model parameters...")
//         print("Attempting to load parameters from: \(modelURL.path)")
//         // This is a simplified approach. Real parameter extraction might be more complex
//         // depending on how Flower expects them and how Core ML stores them.
//         // Often involves iterating through model layers if using MLProgram,
//         // or potentially reading the raw .mlmodelc file structure (which is difficult).
//         // For MLModel, direct access to weights isn't straightforward via public API.
//         // A common workaround is to use the initial model file's data itself
//         // or specific layers if the model architecture allows easy identification.
//
//         // Placeholder: Returning the whole model file data as a single "parameter" tensor.
//         // This is likely NOT correct for actual FL, but serves as a placeholder.
//         // You'll need to adapt this based on Flower's requirements and your model.
//         do {
//             let modelData = try Data(contentsOf: modelURL)
//             print("Loaded initial model data (\(modelData.count) bytes) as parameters.")
//             statusUpdateHandler("Initial parameters loaded.")
//             return [modelData]
//         } catch {
//             print("Error loading model data for parameters: \(error)")
//             statusUpdateHandler("Error: Could not load initial parameters.")
//             return nil
//         }
//    }
//
//    // Update the Core ML model file with new parameters
//    private func updateModelParameters(_ parameters: [Data]) -> Bool {
//        statusUpdateHandler("Updating model with new parameters...")
//        print("Received \(parameters.count) parameter tensors.")
//        // Placeholder: Overwriting the entire model file with the first parameter tensor.
//        // This assumes the server sends back the complete updated model data.
//        // Adapt this logic based on how parameters are structured and need to be applied.
//        guard let newModelData = parameters.first else {
//            print("Error: No parameter data received.")
//            statusUpdateHandler("Error: Invalid parameters received from server.")
//            return false
//        }
//
//        do {
//            try newModelData.write(to: modelURL, options: .atomic)
//            print("Successfully updated model file at: \(modelURL.path)")
//            // Reload the MLModel instance in memory (optional, depends if needed immediately)
//            // let config = MLModelConfiguration()
//            // self.coreMLModel = try MLModel(contentsOf: modelURL, configuration: config)
//            statusUpdateHandler("Model updated with server parameters.")
//            return true
//        } catch {
//            print("Error writing updated model parameters: \(error)")
//            statusUpdateHandler("Error: Failed to save updated parameters.")
//            return false
//        }
//    }
//
//    // --- Flower Client Protocol Methods ---
//
//    func getParameters(req: Flower_Client_GetParametersReq, context: Flower_Client_GetParametersReq.Context) async -> Flower_Client_GetParametersRes {
//        statusUpdateHandler("Server requested parameters.")
//        print("Responding to getParameters request.")
//        guard let params = self.currentModelParameters else {
//            // Indicate error or return empty parameters if loading failed
//             print("Error: Current parameters are nil.")
//             return Flower_Client_GetParametersRes(status: .init(code: .getPropertiesNotImplemented, message: "Model parameters not loaded"), parameters: .init(tensors: [], tensorType: "coreml")) // Or appropriate error status
//        }
//        return Flower_Client_GetParametersRes(
//            status: .init(code: .ok, message: "Success"),
//            parameters: .init(tensors: params, tensorType: "coreml") // Assuming "coreml" is the agreed type
//        )
//    }
//
//    func fit(req: Flower_Client_FitReq, context: Flower_Client_FitReq.Context) async -> Flower_Client_FitRes {
//        statusUpdateHandler("Starting local training (fit)...")
//        print("Received fit request from server.")
//
//        // 1. Update local model with parameters from server
//        guard updateModelParameters(req.parameters.tensors) else {
//            print("Fit failed: Could not update model parameters.")
//            return Flower_Client_FitRes(status: .init(code: .fitNotImplemented, message: "Failed to update model parameters"), parameters: req.parameters, numExamples: 0, metrics: [:]) // Or appropriate error
//        }
//        self.currentModelParameters = req.parameters.tensors // Store the params we are training on
//
//        // 2. Prepare for Training
//        guard let model = try? MLModel(contentsOf: modelURL) else {
//             print("Fit failed: Could not reload model for training.")
//             statusUpdateHandler("Error: Failed to load model for training.")
//             return Flower_Client_FitRes(status: .init(code: .fitNotImplemented, message: "Failed to load model for training"), parameters: req.parameters, numExamples: 0, metrics: [:])
//        }
//
//        // !!! Use updated LandmarkBatchProvider with TrainingDataSample !!!
//        let batchProvider = LandmarkBatchProvider(
//            trainingData: trainData,
//            inputFeatureName: modelInputName,
//            outputFeatureName: modelTargetName // Use the target name for training
//        )
//
//        let trainingConfig = model.configuration // Use existing config or create new MLModelConfiguration()
//        // Configure training parameters if needed (e.g., epochs, learning rate)
//        // trainingConfig.parameters = [.epochs: 5] // Example
//
//        statusUpdateHandler("Training model locally (\(trainData.count) samples)...")
//        print("Starting MLUpdateTask...")
//
//        // 3. Perform Training using MLUpdateTask
//        let updateTask = try! MLUpdateTask(
//            forModelAt: modelURL, // Train the model file directly
//            trainingData: batchProvider,
//            configuration: trainingConfig,
//            completionHandler: { context in
//                // This handler is called *after* training completes.
//                // We need to return the result *synchronously* within the `fit` function.
//                // So, we use a continuation or similar async pattern.
//                print("MLUpdateTask completion handler called.")
//            }
//        )
//
//        // Use an AsyncStream or Continuation to wait for the training to finish
//        let updatedModelParameters: [Data]? = await withCheckedContinuation { continuation in
//            updateTask.resume() // Start the training
//
//            // Monitor progress (optional)
//            let progressObservation = updateTask.progress.observe(\.fractionCompleted) { progress, _ in
//                DispatchQueue.main.async { [weak self] in
//                    self?.statusUpdateHandler("Training progress: \(Int(progress.fractionCompleted * 100))%")
//                }
//                print("Training progress: \(progress.fractionCompleted)")
//            }
//
//            // Set completion handler for the task's context
//            updateTask.updateContext?.completionHandler = { finalContext in
//                progressObservation.invalidate() // Stop observing progress
//                if let error = finalContext.task.error {
//                    print("Fit failed: MLUpdateTask error: \(error)")
//                    DispatchQueue.main.async { [weak self] in
//                         self?.statusUpdateHandler("Error during training: \(error.localizedDescription)")
//                    }
//                    continuation.resume(returning: nil) // Signal failure
//                } else {
//                    print("MLUpdateTask finished successfully.")
//                    DispatchQueue.main.async { [weak self] in
//                         self?.statusUpdateHandler("Local training complete.")
//                    }
//                    // Reload parameters from the updated model
//                    let newParams = self.loadParametersFromModel()
//                    continuation.resume(returning: newParams) // Signal success with new parameters
//                }
//            }
//        }
//
//        // 4. Prepare and Return Response
//        guard let finalParameters = updatedModelParameters else {
//            print("Fit failed: Training task did not return parameters.")
//             statusUpdateHandler("Error: Training failed.")
//            // Return original parameters or indicate error
//            return Flower_Client_FitRes(status: .init(code: .fitNotImplemented, message: "Training task failed"), parameters: req.parameters, numExamples: Int64(trainData.count), metrics: [:])
//        }
//
//        self.currentModelParameters = finalParameters // Update stored parameters
//        print("Fit successful. Returning updated parameters.")
//        statusUpdateHandler("Fit successful. Sending parameters to server.")
//        return Flower_Client_FitRes(
//            status: .init(code: .ok, message: "Success"),
//            parameters: .init(tensors: finalParameters, tensorType: "coreml"),
//            numExamples: Int64(trainData.count),
//            metrics: [:] // Add metrics if needed (e.g., training loss)
//        )
//    }
//
//    func evaluate(req: Flower_Client_EvaluateReq, context: Flower_Client_EvaluateReq.Context) async -> Flower_Client_EvaluateRes {
//        statusUpdateHandler("Starting local evaluation...")
//        print("Received evaluate request from server.")
//
//        // 1. Update local model with parameters from server for evaluation
//         guard updateModelParameters(req.parameters.tensors) else {
//             print("Evaluate failed: Could not update model parameters.")
//             statusUpdateHandler("Error: Failed to update model for evaluation.")
//             return Flower_Client_EvaluateRes(status: .init(code: .evaluateNotImplemented, message: "Failed to update model parameters"), loss: 0.0, numExamples: 0, metrics: [:])
//         }
//
//        // 2. Load Model for Evaluation
//        guard let model = try? MLModel(contentsOf: modelURL) else {
//            print("Evaluate failed: Could not load model for evaluation.")
//            statusUpdateHandler("Error: Failed to load model for evaluation.")
//            return Flower_Client_EvaluateRes(status: .init(code: .evaluateNotImplemented, message: "Failed to load model for evaluation"), loss: 0.0, numExamples: 0, metrics: [:])
//        }
//
//        // 3. Perform Evaluation
//        var correctPredictions = 0
//        var totalLoss: Float = 0.0 // Placeholder for loss calculation
//
//        statusUpdateHandler("Evaluating model locally (\(testData.count) samples)...")
//        // !!! Use testData which is [TrainingDataSample] !!!
//        for item in testData {
//            // !!! Use item.features which is MLMultiArray !!!
//            let inputFeature = MLFeatureValue(multiArray: item.features)
//            let provider = try! MLDictionaryFeatureProvider(dictionary: [modelInputName: inputFeature])
//
//            do {
//                let prediction = try model.prediction(from: provider)
//                // !!! Adapt this based on your model's output !!!
//                // Assuming output is a dictionary with probabilities per label
//                if let outputProbabilities = prediction.featureValue(for: modelOutputName)?.dictionaryValue {
//                    // Find the label with the highest probability
//                    if let predictedLabel = outputProbabilities.max(by: { $0.value.doubleValue < $1.value.doubleValue })?.key as? String {
//                        // !!! Compare with item.label !!!
//                        if predictedLabel == item.label {
//                            correctPredictions += 1
//                        }
//                        // Placeholder for loss calculation - requires knowing the model's loss function
//                        // e.g., if outputProbabilities contains probability for the true label:
//                        // let trueLabelProb = outputProbabilities[item.label]?.floatValue ?? 0.0
//                        // totalLoss -= log(max(trueLabelProb, 1e-9)) // Example: Cross-entropy loss
//                    }
//                } else if let outputLabel = prediction.featureValue(for: modelOutputName)?.stringValue {
//                     // Handle case where output is directly a string label
//                     // !!! Compare with item.label !!!
//                     if outputLabel == item.label {
//                         correctPredictions += 1
//                     }
//                     // Loss calculation might be different here (e.g., 0/1 loss)
//                     totalLoss += (outputLabel == item.label ? 0.0 : 1.0)
//                } else {
//                    print("Warning: Could not interpret model output for evaluation.")
//                }
//
//            } catch {
//                print("Error during evaluation prediction: \(error)")
//                // Decide how to handle prediction errors (e.g., count as incorrect)
//            }
//        }
//
//        let accuracy = testData.isEmpty ? 0.0 : Double(correctPredictions) / Double(testData.count)
//        let averageLoss = testData.isEmpty ? 0.0 : totalLoss / Float(testData.count) // Ensure division by zero is handled
//
//        print("Evaluation finished. Accuracy: \(accuracy), Loss: \(averageLoss)")
//        statusUpdateHandler("Evaluation complete. Accuracy: \(String(format: "%.2f", accuracy * 100))%")
//
//        // 4. Return Results
//        return Flower_Client_EvaluateRes(
//            status: .init(code: .ok, message: "Success"),
//            loss: averageLoss, // Report average loss
//            numExamples: Int64(testData.count),
//            metrics: ["accuracy": .double(accuracy)] // Send accuracy as a metric
//        )
//    }
//
//    // Optional: Implement getProperties if needed by your strategy
//    func getProperties(req: Flower_Client_GetPropertiesReq, context: Flower_Client_GetPropertiesReq.Context) async -> Flower_Client_GetPropertiesRes {
//         print("Responding to getProperties request.")
//         // Example: Return number of training examples
//         let properties: [String: Flower_Scalar] = ["num_train_examples": .sint64(Int64(trainData.count))]
//         return Flower_Client_GetPropertiesRes(
//             status: .init(code: .ok, message: "Success"),
//             properties: properties
//         )
//     }
//}
//
