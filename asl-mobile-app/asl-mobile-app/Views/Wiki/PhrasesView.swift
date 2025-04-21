//
//  PhrasesView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 18.04.2025.
//

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
                                .foregroundColor(.orange)
                        }
                    }
                    .disabled(phrase.status == PhraseStatus.Available)
                    
                    Spacer()
                    
                    if phrase.status == PhraseStatus.Available {
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
                        .disabled(viewModel.money < phrase.price || phrase.status == PhraseStatus.Purchased)
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

struct PhraseDetailView: View {
    let phrase: Phrase
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                    
                    Text("GIF: \(phrase.s3Url)")
                        .font(.caption)
                        .foregroundColor(.gray)
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
                        .foregroundColor(.main)
                    
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
    }
}

struct SignCardView: View {
    let sign: Sign
    
    var body: some View {
        NavigationLink(destination: SignDetailView(sign: sign)) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 100, height: 100)
                        
                        Text("GIF")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(sign.name)
                            .font(.headline)
                        
                        Text(sign.meaning)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Difficulty: \(sign.difficulty)")
                            .font(.caption)
                            .foregroundColor(.main)
                        
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
