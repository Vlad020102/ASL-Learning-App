//
//  PhrasesView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 18.04.2025.
//
//TODO:
// 1. color based on difficulty
// 2. rounded corners for the cards

import SwiftUI

struct PhrasesView: View {
    @EnvironmentObject private var viewModel: WikiViewModel
    
    
    var body: some View {
        List {
            ForEach(viewModel.filteredPhrases, id: \.id) { (phrase: Phrase) in
                HStack {
                    NavigationLink(destination: PhraseDetailView(phrase: phrase)) {
                        VStack(alignment: .leading) {
                            Text(phrase.name)
                                .font(.headline)
                            
                            Text("Difficulty: \(phrase.difficulty)")
                                .font(.caption)
                                .foregroundColor(phrase.difficultyColor)
                        }
                    }
                    .disabled(phrase.status == PhraseStatus.Available)
                    
                    Spacer()
                    
                    if phrase.status == PhraseStatus.Finished {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button(action: {
                            viewModel.purchasePhrase(phrase: phrase)
                        }) {
                            HStack {
                                Text("\(phrase.price)")
                                    .fontWeight(.bold)
                                
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .disabled(phrase.status == PhraseStatus.Purchased)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
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
        .background(Color.background)
        .scrollContentBackground(.hidden)
    }
}

struct PracticePhraseCameraView: View {
    // Use @State for targetSign as HolisticCameraView takes a Binding
    @State var phraseName: String 
    @Binding var showPracticeView: Bool
    
    @State private var modelRespondedCorrectly: Bool = false
    @State private var showSuccessMessage: Bool = false
    @State private var successMessageText: String = "Correct!"

    var body: some View {
        ZStack {
            // Embed HolisticCameraView
            HolisticCameraView(targetSign: $phraseName, isCorrectSign: $modelRespondedCorrectly)
                .ignoresSafeArea()
                .onAppear {
                    // HolisticCameraView itself handles setting the targetSign in PredictionViewModel
                    // and updating its isCorrectSign binding from PredictionViewModel.
                    // We just need to ensure our local states are reset.
                    modelRespondedCorrectly = false
                    showSuccessMessage = false
                }
                .onChange(of: modelRespondedCorrectly) { newValue in
                    // This will be triggered when HolisticCameraView updates its isCorrectSign binding,
                    // which in turn is updated from PredictionViewModel.shared.$isCorrectSign.
                    if newValue && !showSuccessMessage { // Check !showSuccessMessage to prevent re-triggering while message is shown
                        successMessageText = "Great! \"\(phraseName)\" performed correctly!"
                        showSuccessMessage = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showSuccessMessage = false
                            // Important: Reset modelRespondedCorrectly to allow for re-detection
                            // if the user continues to hold the sign or performs it again.
                            // HolisticCameraView will also see this change.
                            modelRespondedCorrectly = false
                            // Also reset the global prediction state if needed, though HolisticCameraView might do this.
                            PredictionViewModel.shared.isCorrectSign = false
                        }
                    }
                }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showPracticeView = false
                        // PredictionViewModel.shared.setTargetSign("") // Optional: Clear target
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
                
                Text("Practice the phrase: \(phraseName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
            
            if showSuccessMessage {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack {
                        Text(successMessageText)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.green.opacity(0.85))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .multilineTextAlignment(.center)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .padding(.horizontal, 40) // Ensure text fits
                }
                .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
            }
        }
    }
}

struct PhraseDetailView: View {
    let phrase: Phrase
    @State private var showPracticePhraseView: Bool = false // New state variable
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(spacing: 20) {       
                    GIFView(gifName: phrase.s3Url)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                    
                }
            }
            .padding(.horizontal)
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    Text(phrase.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textSecondary)
                    
                    Text(phrase.meaning)
                        .font(.subheadline)
                        .foregroundColor(.accent3)
                    
                    Text("Difficulty: \(phrase.difficulty)")
                        .font(.caption)
                        .foregroundColor(phrase.difficultyColor)
                    
                }
                .padding()
                
                Divider()
                
                Text("Signs in this phrase")
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundColor(.textSecondary)

                
                ForEach(phrase.signs) { sign in
                    SignCardView(sign: sign)
                        .padding(.horizontal)
                }
                
                Text("How to sign this phrase")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                    .foregroundColor(.textSecondary)

                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array((phrase.explanation ?? []).enumerated()), id: \.element) { index, explanation in
                        Text("\(index + 1). \(explanation)")
                    }
                }
                .padding()
                .background(Color.accent3)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Button(action: {
                    showPracticePhraseView = true // Update action
                }) {
                    Text("Practice this phrase")
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
                Text("Phrase Detail")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .fullScreenCover(isPresented: $showPracticePhraseView) { // Add fullScreenCover
            PracticePhraseCameraView(phraseName: phrase.name, showPracticeView: $showPracticePhraseView)
        }
    }
}

struct SignCardView: View {
    let sign: Sign
    
    var body: some View {
        NavigationLink(destination: SignDetailView(sign: sign)) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    ZStack {
                        GIFView(gifName: sign.s3Url)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 100, height: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(sign.name)
                            .font(.headline)
                        
                        Text(sign.meaning ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Difficulty: \(sign.difficulty)")
                            .font(.caption)
                            .foregroundColor(sign.difficultyColor)
                        
                        Text("Tap to see details")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.accent3)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
