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
        AuthManager.shared.setToken(with: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImxvbCIsInN1YiI6MSwiaWF0IjoxNzQ1MDAxMzg3LCJleHAiOjE3NDUwMDQ5ODd9.mRhozyJ2Gsq7EGDY6m9LsFfO7caVYlJ45rkyxxFUkSg")
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

        .background(Color.background)
        .onAppear {
            viewModel.loadWikiData()
        }
    }
}

struct WikiView_Preview: PreviewProvider {
    static var previews: some View {
        WikiView()
    }
}

