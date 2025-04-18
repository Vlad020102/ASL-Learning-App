//
//  WikiView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 13.04.2025.
//

import SwiftUI

class WikiViewModel: ObservableObject {
    @Published var currency = 100
    @Published var signs: [Sign] = []
    @Published var phrases: [Phrase] = []
    
    func loadWikiData() {
        AuthManager.shared.setToken(with: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImxvbCIsInN1YiI6MSwiaWF0IjoxNzQ0OTg5NTYzLCJleHAiOjE3NDQ5OTMxNjN9.nlydVFqrCyf2acZOYzADjJoaF9OBo9eORI2DyOAVz-U")
        NetworkService.shared.fetchPhrases { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("here")
                        self?.phrases = response.phrases
                        self?.signs = response.signs
                    case .failure(let error):
                        print("Error fetching phrases: \(error)")
                        // You might want to add error handling here
                    }
                }
            }
        }
    
    func purchasePhrase(
        _ phrase: Phrase
    ) -> Bool {
        guard let index = phrases.firstIndex(
            where: {
                $0.id == phrase.id
            }) else {
            return false
        }
       
       if currency >= phrase.price {
           currency -= phrase.price
//           phrases[index].status = "In Progress"
           return true
       }
       return false
   }
}

struct WikiView: View {
   @StateObject private var viewModel = WikiViewModel()
   
   var body: some View {
       TabView {
           PhrasesView()
               .environmentObject(viewModel)
               .tabItem {
                   Label("Phrases", systemImage: "text.bubble")
               }
           
           SignsView()
               .environmentObject(viewModel)
               .tabItem {
                   Label("Signs", systemImage: "hand.raised")
               }
       }
   }
}

struct PhrasesView: View {
    @EnvironmentObject private var viewModel: WikiViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.phrases, id: \.id) { (phrase: Phrase) in
                    NavigationLink(destination: PhraseDetailView(phrase: phrase)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(phrase.name)
                                    .font(.headline)
                                
                                Text("Difficulty: \(phrase.difficulty)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            
                            Spacer()
                            
                            if phrase.status == "In Progress" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Button(action: {
                                    _ = viewModel.purchasePhrase(phrase)
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
                                .disabled(viewModel.currency < phrase.price)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(phrase.status == "In Progress")
                }
            }
            .navigationTitle("ASL Phrases")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Text("\(viewModel.currency)")
                            .fontWeight(.bold)
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadWikiData()
        }
    }
}

struct PhraseDetailView: View {
   let phrase: Phrase
   
   var body: some View {
       ScrollView {
           VStack(alignment: .leading, spacing: 20) {
               // Header section
               VStack(alignment: .leading, spacing: 8) {
                   Text(phrase.name)
                       .font(.largeTitle)
                       .fontWeight(.bold)
                   
                   Text(phrase.meaning)
                       .font(.subheadline)
                       .foregroundColor(.secondary)
                   
                   Text("Difficulty: \(phrase.difficulty)")
                       .font(.caption)
                       .foregroundColor(.orange)
               }
               .padding()
               .frame(maxWidth: .infinity, alignment: .leading)
               .background(Color.blue.opacity(0.1))
               .cornerRadius(12)
               
               Text("Signs in this phrase")
                   .font(.headline)
                   .padding(.horizontal)
               
               ForEach(phrase.signs) { sign in
                   SignCardView(sign: sign)
                       .padding(.horizontal)
               }
               
               Text("How to sign this phrase")
                   .font(.headline)
                   .padding(.horizontal)
                   .padding(.top)
               
               VStack(alignment: .leading, spacing: 12) {
                   ForEach(Array((phrase.explanation ?? []).enumerated()), id: \.element) { index,         explanation in
                            Text("\(index + 1). \(explanation)")
                        }
                    }
               .padding()
               .background(Color.gray.opacity(0.1))
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
       .navigationTitle("Learn Phrase")
       .navigationBarTitleDisplayMode(.inline)
   }
}

struct SignCardView: View {
    let sign: Sign
    
    var body: some View {
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
                        .foregroundColor(.orange)
                    
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

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


struct WikiView_Preview: PreviewProvider {
    static var previews: some View {
        WikiView()
    }
}

