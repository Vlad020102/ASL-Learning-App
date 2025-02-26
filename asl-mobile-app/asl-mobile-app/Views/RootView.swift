import SwiftUI

struct RootView: View {
    enum Tab {
        case camera, mediaLibrary
    }

    @State private var selectedTab: Tab = .camera
    @State private var isBottomSheetOpen: Bool = false
    @State private var inferenceTime: String = ""

    var body: some View {
        ZStack {
            VStack {
                // Tab View for switching between Camera and Media Library
                TabView(selection: $selectedTab) {
                    CameraAppView(inferenceTime: $inferenceTime, isBottomSheetOpen: $isBottomSheetOpen)
                        .tabItem {
                            Label("Camera", systemImage: "camera.fill")
                        }
                        .tag(Tab.camera)

                    MediaLibraryView(inferenceTime: $inferenceTime, isBottomSheetOpen: $isBottomSheetOpen)
                        .tabItem {
                            Label("Library", systemImage: "photo.fill")
                        }
                        .tag(Tab.mediaLibrary)
                }
            }
            
            // Bottom Sheet for inference results
            BottomSheetView(isOpen: $isBottomSheetOpen, inferenceTime: $inferenceTime)
        }
    }
}

struct CameraAppView: View {
    @Binding var inferenceTime: String
    @Binding var isBottomSheetOpen: Bool

    var body: some View {
        VStack {
            Text("Camera View")
                .font(.largeTitle)
                .padding()

            Button("Perform Inference") {
                // Simulate inference and update time
                inferenceTime = String(format: "%.2fms", Double.random(in: 10...50))
                isBottomSheetOpen = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct MediaLibraryView: View {
    @Binding var inferenceTime: String
    @Binding var isBottomSheetOpen: Bool

    var body: some View {
        VStack {
            Text("Media Library View")
                .font(.largeTitle)
                .padding()

            Button("Perform Inference on Image") {
                inferenceTime = String(format: "%.2fms", Double.random(in: 10...50))
                isBottomSheetOpen = true
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// Bottom Sheet View
struct BottomSheetView: View {
    @Binding var isOpen: Bool
    @Binding var inferenceTime: String

    var body: some View {
        VStack {
            Spacer()
            if isOpen {
                VStack {
                    HStack {
                        Text("Inference Time: \(inferenceTime)")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            isOpen.toggle()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .frame(height: 200)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isOpen)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
