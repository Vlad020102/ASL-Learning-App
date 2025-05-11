//import SwiftUI
//
//struct FederatedLearningView: View {
//    // Use @StateObject to create and keep the manager alive for the view's lifecycle
//    @StateObject private var federatedManager = FederatedLearningManager()
//    // Optional: If you have a real data source, inject it:
//    // @StateObject private var federatedManager: FederatedLearningManager
//    // init(dataSource: HandLandmarkDataSource) {
//    //     _federatedManager = StateObject(wrappedValue: FederatedLearningManager(landmarkDataSource: dataSource))
//    // }
//
//    // State for the label to train (could be dynamic later)
//    @State private var trainingLabel: String = "Please"
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Federated Learning Control")
//                .font(.title)
//
//            // Display the current status from the manager
//            Text("Status: \(federatedManager.status)")
//                .padding()
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(8)
//
//            // Input for the training label (optional)
//            HStack {
//                Text("Training Label:")
//                TextField("Enter label (e.g., Please)", text: $trainingLabel)
//                    .textFieldStyle(.roundedBorder)
//                    .disabled(federatedManager.isRunning)
//            }
//
//            // Start Button
//            Button("Start Training Round") {
//                federatedManager.startFederatedLearning(label: trainingLabel)
//            }
//            .padding()
//            .background(federatedManager.isRunning ? Color.gray : Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .disabled(federatedManager.isRunning)
//
//            // Stop Button
//            Button("Stop Training Round") {
//                federatedManager.stopFederatedLearning()
//            }
//            .padding()
//            .background(federatedManager.isRunning ? Color.red : Color.gray)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .disabled(!federatedManager.isRunning)
//
//            Spacer()
//        }
//        .padding()
//        // Ensure disconnection when the view disappears
//        .onDisappear {
//            federatedManager.stopFederatedLearning()
//        }
//    }
//}
//
//struct FederatedLearningView_Previews: PreviewProvider {
//    static var previews: some View {
//        FederatedLearningView()
//    }
//}
