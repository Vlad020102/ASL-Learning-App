//
//  SignsView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 18.04.2025.
//
import SwiftUI

struct SignsView: View {
    @EnvironmentObject private var viewModel: WikiViewModel
    @State private var searchText = ""
    
    var filteredSigns: [Sign] {
        if searchText.isEmpty {
            return viewModel.signs
        } else {
            return viewModel.signs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredSigns) { (sign: Sign) in
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
                                
                                Text(sign.meaning)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                            
                            Spacer()
                            
                            Text("Difficulty: \(sign.difficulty)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search signs")
            .navigationTitle("All Discovered Signs")
        }
    }
}

struct SignDetailView: View {
    let sign: Sign
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                    
                    Text("GIF: \(sign.s3Url)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Sign information
                VStack(alignment: .leading, spacing: 12) {
                    Text(sign.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(sign.meaning)
                        .font(.title3)
                        .foregroundColor(.alternative)
                    
                    Text("Difficulty: \(sign.difficulty)")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Divider()
                    
                    Text("Description: \(sign.description ?? "A common sign")")
                        .font(.headline)
                        .foregroundColor(.alternative)
                    
                    Text("How to perform this sign:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array((sign.explanation ?? []).enumerated()), id: \.element) { index,         explanation in
                            Text("\(index + 1). \(explanation)")
                        }
                    }
                    .padding(.leading)
                    
                    Divider()
                    
                    Text("Used in these phrases:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // Would be dynamically generated based on phrases using this sign
                    Text("• My name is...")
                    Text("• Nice to meet you")
                }
                .padding()
                
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
                
                // "Find more phrases" button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Find more signs")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.main)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Sign Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
