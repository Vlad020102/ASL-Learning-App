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

struct SignDetailView: View {
    let sign: Sign
    @Environment(\.presentationMode) var presentationMode
    
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
                    // Future implementation for practice feature
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
    }
}
