//
//  ContentPost.swift
//  asl-mobile-app
//
//  Created by vlad.achim on 07.05.2025.

import SwiftUI

class ExploreViewModel: ObservableObject {
    @Published var featuredContent: [ExtraItem] = []
    @Published var latestContent: [ExtraItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab: ExtraType = ExtraType.Podcast.self
    @Published var showReferralSheet = false
    func loadContent() {
        isLoading = true
        errorMessage = nil
        NetworkService.shared.fetchExplore { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    var media: [ExtraItem] = []
                    var latest: [ExtraItem] = []
                                        
                    if let games = response.extras.Game {
                        media.append(contentsOf: games)
                        latest.append(contentsOf: games)
                    }
                    if let movies = response.extras.Movie {
                        media.append(contentsOf: movies)
                        latest.append(contentsOf: movies)
                    }
                    if let books = response.extras.Book {
                        latest.append(contentsOf: books)
                    }
                   
                    if let articles = response.extras.Article {
                        latest.append(contentsOf: articles)
                    }
                    if let news = response.extras.News {
                        latest.append(contentsOf: news)
                    }
                    self?.latestContent = latest
                    
                    if let events = response.extras.Event {
                        latest.append(contentsOf: events)
                    }
                    if let podcasts = response.extras.Podcast {
                        media.append(contentsOf: podcasts)
                        latest.append(contentsOf: podcasts)
                    }
                    
                    self?.latestContent = latest
                    self?.featuredContent = media
                    
                case .failure(let error):
                    print(error)
                    self?.errorMessage = "Failed to load explore page: \(error.localizedDescription)"
                }
            }
        }
    }

    
    func filteredContent() -> [ExtraItem] {
        return latestContent.filter { $0.type == selectedTab }
    }
}

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage, retryAction: {
                            viewModel.loadContent()
                        })
                    } else {
                        // Featured Content Section
                        VStack(alignment: .leading) {
                            Text("Featured")
                                .foregroundColor(.alternative)
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                FeaturedPostsView(featurePosts: viewModel.featuredContent)
                            }
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Latest Content")
                                .foregroundColor(.alternative)
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ContentTabView(
                                selectedTab: $viewModel.selectedTab
                            )
                            
                            ForEach(viewModel.filteredContent()) { post in
                                ContentPostCard(post: post)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.background)
            .onAppear {
                viewModel.loadContent()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Explore")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                }
            }
            .toolbarBackground(Color.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
struct FeaturedPostsView: View{
    var featurePosts: [ExtraItem]
    var body: some View{
        HStack(spacing: 16) {
            ForEach(featurePosts) { post in
                FeaturedPostCard(post: post)
            }
        }
        .padding(.horizontal)
    }
}

struct ContentTabView: View {
    @Binding var selectedTab: ExtraType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ExtraType.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.subheadline)
                            
                            Text(tab.displayName)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedTab == tab ? circleColorFor(type: selectedTab.displayName) : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct FeaturedPostCard: View {
    let post: ExtraItem
    
    var body: some View {
        Button(action: {
            if let URL = URL(string: post.link){
                UIApplication.shared.open(URL)
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Image area with centered icon
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 150)
                    
                    Image(systemName: post.type.icon)
                        .font(.system(size: 40))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
                
                // Content area at bottom
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    Text(post.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .opacity(0.8)
                    
                    // Category label at bottom
                    HStack {
                        CategoryPill(text: post.type.displayName, icon: post.type.icon)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
                .padding(12)
            }
            .frame(width: 280)
            .background(.accent3)
            .cornerRadius(16)
        }
    }
}

// Rounded pill for category display
struct CategoryPill: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(circleColorFor(type: text).opacity(0.2))
        .foregroundColor(circleColorFor(type: text))
        .cornerRadius(16)
    }
}


struct ContentPostCard: View {
    let post: ExtraItem

    
    var body: some View {
        Button(action: {
            // In a real app, this would open the content link
            if let URL = URL(string: post.link){
                UIApplication.shared.open(URL)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Circle()
                        .fill(circleColorFor(type: post.type.displayName))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: post.type.icon)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.title)
                            .font(.headline)
                            .foregroundColor(.text)
                        
                        Text(post.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.accent3)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Section: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(circleColorFor(type: text))
        .cornerRadius(4)
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.bottom, 20)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}


func circleColorFor(type: String) -> Color {
    switch type {
    case "Podcast": return Color.purple
    case "Movie": return Color.blue
    case "Article": return Color.green
    case "News": return Color.orange
    case "Book": return Color.red
    case "Event": return Color.cyan
    case "Game": return Color.alternative
    default: return Color.pink
    }
}
