//
//  SignsView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 18.04.2025.
//
import SwiftUI

struct SignsView: View {
    @EnvironmentObject private var viewModel: WikiViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.filteredSigns) { (sign: Sign) in
                NavigationLink(destination: SignDetailView(sign: sign)) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Text(String(sign.name.prefix(1)))
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(sign.name)
                                .font(.headline)
                            
                            Text(sign.meaning ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        Text("Difficulty: \(sign.difficulty)")
                            .font(.caption)
                            .foregroundColor(sign.difficultyColor)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.accent3)
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accent3)
                )
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color.background)
    }
}

struct PracticeCameraView: View {
    let signName: String
    @Binding var showPracticeView: Bool
    
    @State private var modelRespondedCorrectly: Bool = false
    @State private var showSuccessMessage: Bool = false // New state for success message visibility
    @State private var successMessageText: String = "Correct!" // New state for the message text

    var body: some View {
        ZStack {
            SimpleHostedViewController(modelType: "Simple", targetSign: signName, isCorrectSign: modelRespondedCorrectly)
                .ignoresSafeArea()
                .onAppear {
                    PredictionViewModel.shared.setTargetSign(signName)
                    PredictionViewModel.shared.isCorrectSign = false
                    modelRespondedCorrectly = false
                    showSuccessMessage = false // Ensure message is hidden on appear
                }
                .onReceive(PredictionViewModel.shared.$isCorrectSign) { isCorrectNow in
                    print(isCorrectNow)
                    if isCorrectNow && !modelRespondedCorrectly { // Process only new correct predictions
                        modelRespondedCorrectly = true
                        successMessageText = "Correct: \(signName)!"
                        showSuccessMessage = true
                        
                        // Hide the message after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSuccessMessage = false
                            // Optionally reset modelRespondedCorrectly if you want the user to be able to get "Correct" feedback multiple times for the same sign without closing and reopening
                             modelRespondedCorrectly = false 
                             PredictionViewModel.shared.isCorrectSign = false 
                        }
                    }
                }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showPracticeView = false
                        // Optional: Clear the target sign when practice view is dismissed
                        // PredictionViewModel.shared.setTargetSign("") // or some default
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.top)
                .padding(.trailing)
                
                Spacer()
                
                Text("Practice the sign: \(signName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
            
            // Success message overlay
            if showSuccessMessage {
                ZStack {
                    Color.black.opacity(0.4) // Semi-transparent background
                        .ignoresSafeArea()
                    
                    VStack {
                        Text(successMessageText)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
            }
        }
    }
}

struct SignDetailView: View {
    let sign: Sign
    @Environment(\.presentationMode) var presentationMode
    @State private var showPracticeView: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    GIFView(gifName: sign.s3Url)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Sign information
                VStack(alignment: .leading, spacing: 12) {
                    Text(sign.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(sign.meaning ?? "")
                        .font(.title3)
                        .foregroundColor(.alternative)
                    
                    Text("Difficulty: \(sign.difficulty)")
                        .font(.caption)
                        .foregroundColor(sign.difficultyColor)
                    
                    Divider()
                    
                    Text("Description: \(sign.description ?? "A common sign")")
                        .font(.headline)
                        .foregroundColor(.alternative)
                    
                    Text("How to perform this sign:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array((sign.explanation ?? []).enumerated()), id: \.element) { index, explanation in
                            Text("\(index + 1). \(explanation)")
                        }
                    }
                    .padding(.leading)
                    
                    Divider()
                    
                    Text("Used in these phrases:")
                        .font(.headline)
                        .padding(.top, 8)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array((sign.usedIn ?? []).enumerated()), id: \.element) { index, phraseName in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")  // Bullet point character
                                Text(phraseName)
                            }
                        }
                    }
                    .padding(.leading)
                }
                .padding()
                .background(Color.accent3)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Practice button
                Button(action: {
                    showPracticeView = true
                }) {
                    Text("Practice this sign")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sign Details")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(isPresented: $showPracticeView) {
            PracticeCameraView(signName: sign.name, showPracticeView: $showPracticeView)
        }
    }
}
