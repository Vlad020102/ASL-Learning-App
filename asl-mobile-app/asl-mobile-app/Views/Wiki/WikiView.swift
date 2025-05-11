//
//  WikiView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 13.04.2025.
//

import SwiftUI

class WikiViewModel: ObservableObject {
    @Published var signs: [Sign] = []
    @Published var phrases: [Phrase] = []
    @Published var searchText = ""
    @Published var money: Int = 0
    
    
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func loadWikiData() {
        self.isLoading = true
        errorMessage = nil
       
        NetworkService.shared.fetchPhrases { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.phrases = response.phrases
                    self?.signs = response.signs
                    self?.money = response.money
                case .failure(let error):
                    self?.errorMessage = "Failed to load phrases and signs: \(error.localizedDescription)"
                }
            }
        }
    }
    
    var filteredSigns: [Sign] {
        if searchText.isEmpty {
            return signs
        } else {
            return signs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var filteredPhrases: [Phrase] {
        if searchText.isEmpty {
            return phrases
        } else {
            return phrases.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func purchasePhrase(phrase: Phrase) {
        guard money >= phrase.price else { return }
        
        NetworkService.shared.purchasePhrase(id: phrase.id, data: PurchasePhraseData(status: phrase.status.rawValue, price: phrase.price)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let index = self?.phrases.firstIndex(where: { $0.id == phrase.id }) {
                        self?.phrases[index] = response
                        self?.money -= phrase.price
                    }
                case .failure(let error):
                    print("Failed to purchase phrase: \(error)")
                    self?.errorMessage = "Failed to purchase phrase: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct WikiView: View {
    @StateObject private var viewModel = WikiViewModel()
    @State private var selectedView = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Search...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.background)
                
                Picker("View Selection", selection: $selectedView) {
                    Text("Phrases").tag(0)
                    Text("Signs").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage, retryAction: {
                        print("here")
                        viewModel.loadWikiData()
                    })
                } else {
                    if selectedView == 0 {
                        PhrasesView()
                            .environmentObject(viewModel)
                    } else {
                        
                        SignsView()
                            .environmentObject(viewModel)
                    }
                    
                    Spacer()
                }
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(selectedView == 0 ? "All Phrases" : "All Discovered Signs")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Text("\(viewModel.money)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                    }
                }
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
