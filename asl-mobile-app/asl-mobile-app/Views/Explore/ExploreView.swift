//
//  ContentPost.swift
//  asl-mobile-app
//
//  Created by vlad.achim on 07.05.2025.

import SwiftUI

struct ContentPost: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let imageURL: String?
    let type: ContentType
    let link: String
    let postDate: Date
    let likes: Int
    var isLiked: Bool = false
    
    enum ContentType: String, CaseIterable {
        case podcast
        case movie
        case article
        case news
        case event
        
        var icon: String {
            switch self {
            case .podcast: return "headphones"
            case .movie: return "film"
            case .article: return "doc.text"
            case .news: return "newspaper"
            case .event: return "calendar"
            }
        }
        
        var displayName: String {
            return self.rawValue.capitalized
        }
    }
}

class ExploreViewModel: ObservableObject {
    @Published var featuredContent: [ContentPost] = []
    @Published var latestContent: [ContentPost] = []
    @Published var communityResources: [ContentPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab: ContentPost.ContentType = .podcast
    @Published var showReferralSheet = false
    @Published var referralCode: String = ""
    @Published var showCopiedToast = false
    
    func loadContent() {
        isLoading = true
        errorMessage = nil
        
        // Mock data for now - would be replaced with API calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            self?.featuredContent = Self.mockFeaturedContent()
            self?.latestContent = Self.mockLatestContent()
            self?.communityResources = Self.mockCommunityResources()
            self?.referralCode = "ASL2025FRIEND"
        }
    }
    
    func likePost(_ post: ContentPost) {
        if let index = featuredContent.firstIndex(where: { $0.id == post.id }) {
            featuredContent[index].isLiked.toggle()
        }
        
        if let index = latestContent.firstIndex(where: { $0.id == post.id }) {
            latestContent[index].isLiked.toggle()
        }
        
        if let index = communityResources.firstIndex(where: { $0.id == post.id }) {
            communityResources[index].isLiked.toggle()
        }
    }
    
    func copyReferralCode() {
        UIPasteboard.general.string = referralCode
        withAnimation {
            showCopiedToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                self.showCopiedToast = false
            }
        }
    }
    
    func shareReferralCode() {
        let shareText = "Join me on ASLearning! Use my referral code \(referralCode) and we'll both get 100 units. Download the app now!"
        let av = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    func filteredContent() -> [ContentPost] {
        return latestContent.filter { $0.type == selectedTab }
    }
    
    private static func mockFeaturedContent() -> [ContentPost] {
        return [
            ContentPost(id: "f1", title: "ASL in Media", description: "How American Sign Language is transforming media representation", imageURL: nil, type: .article, link: "https://example.com/asl-media", postDate: Date().addingTimeInterval(-86400*2), likes: 145, isLiked: false),
            ContentPost(id: "f2", title: "CODA: A Breakthrough Film", description: "The Oscar-winning film that brought Deaf culture to mainstream audiences", imageURL: nil, type: .movie, link: "https://example.com/coda", postDate: Date().addingTimeInterval(-86400*7), likes: 289, isLiked: true)
        ]
    }
    
    private static func mockLatestContent() -> [ContentPost] {
        return [
            ContentPost(id: "l1", title: "Sign Language Today Podcast", description: "Weekly discussions on ASL learning and Deaf culture", imageURL: nil, type: .podcast, link: "https://example.com/podcast1", postDate: Date().addingTimeInterval(-86400), likes: 42, isLiked: false),
            ContentPost(id: "l2", title: "Silent Voices", description: "Documentary exploring the rich history of ASL", imageURL: nil, type: .movie, link: "https://example.com/silent-voices", postDate: Date().addingTimeInterval(-86400*3), likes: 78, isLiked: false),
            ContentPost(id: "l3", title: "Advancements in ASL Recognition Technology", description: "New AI models are making ASL more accessible", imageURL: nil, type: .article, link: "https://example.com/asl-tech", postDate: Date().addingTimeInterval(-86400*4), likes: 63, isLiked: true),
            ContentPost(id: "l4", title: "Deaf Awareness Week Events", description: "National celebrations and educational opportunities", imageURL: nil, type: .news, link: "https://example.com/deaf-awareness", postDate: Date().addingTimeInterval(-86400*2), likes: 51, isLiked: false),
            ContentPost(id: "l5", title: "ASL Poetry Night", description: "Virtual gathering of ASL poets and storytellers", imageURL: nil, type: .event, link: "https://example.com/asl-poetry", postDate: Date().addingTimeInterval(-86400*5), likes: 34, isLiked: false),
            ContentPost(id: "l6", title: "Signs of Change Podcast", description: "Interviews with Deaf activists and educators", imageURL: nil, type: .podcast, link: "https://example.com/signs-change", postDate: Date().addingTimeInterval(-86400*6), likes: 29, isLiked: false)
        ]
    }
    
    private static func mockCommunityResources() -> [ContentPost] {
        return [
            ContentPost(id: "c1", title: "National Association of the Deaf", description: "Civil rights organization serving deaf and hard-of-hearing individuals", imageURL: nil, type: .article, link: "https://nad.org", postDate: Date().addingTimeInterval(-86400*10), likes: 112, isLiked: false),
            ContentPost(id: "c2", title: "ASL Connect", description: "Free ASL learning resources from Gallaudet University", imageURL: nil, type: .article, link: "https://aslconnect.gallaudet.edu", postDate: Date().addingTimeInterval(-86400*12), likes: 95, isLiked: true),
            ContentPost(id: "c3", title: "Deaf Culture Events Calendar", description: "Nationwide events celebrating Deaf culture and ASL", imageURL: nil, type: .event, link: "https://example.com/deaf-events", postDate: Date().addingTimeInterval(-86400*15), likes: 73, isLiked: false)
        ]
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
                                HStack(spacing: 16) {
                                    ForEach(viewModel.featuredContent) { post in
                                        FeaturedPostCard(post: post) {
                                            viewModel.likePost(post)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Referral Section
                        ReferralView(
                            referralCode: viewModel.referralCode,
                            showCopiedToast: $viewModel.showCopiedToast,
                            copyAction: {
                                viewModel.copyReferralCode()
                            },
                            shareAction: {
                                viewModel.shareReferralCode()
                            }
                        )
                        
                        // Content Tabs Section
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
                                ContentPostCard(post: post) {
                                    viewModel.likePost(post)
                                }
                            }
                        }
                        
                        // Community Resources Section
                        VStack(alignment: .leading) {
                            Text("Community Resources")
                                .foregroundColor(.alternative)
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ForEach(viewModel.communityResources) { resource in
                                ContentPostCard(post: resource) {
                                    viewModel.likePost(resource)
                                }
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
            .overlay(
                Group {
                    if viewModel.showCopiedToast {
                        ToastView(message: "Referral code copied!")
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: viewModel.showCopiedToast)
                    }
                }
            )
        }
    }
}

struct ReferralView: View {
    var referralCode: String
    @Binding var showCopiedToast: Bool
    var copyAction: () -> Void
    var shareAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Invite Friends")
                .foregroundColor(.alternative)
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.accent1)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Get 100 units for each friend who joins")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Share your referral code below")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Text(referralCode)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Button(action: copyAction) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accent1.opacity(0.2))
                            .foregroundColor(.accent1)
                            .cornerRadius(8)
                    }
                    
                    Button(action: shareAction) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accent1)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(.accent3)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ContentTabView: View {
    @Binding var selectedTab: ContentPost.ContentType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ContentPost.ContentType.allCases, id: \.self) { tab in
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
                        .background(selectedTab == tab ? Color.accent1 : Color.gray.opacity(0.2))
                        .foregroundColor(selectedTab == tab ? .white : .primary)
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
    let post: ContentPost
    let likeAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = post.imageURL {
                // Image would load from URL in a real app
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: post.type.icon)
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: post.type.icon)
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(post.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Section(text: post.type.displayName, icon: post.type.icon)
                    
                    Spacer()
                    
                    Button(action: likeAction) {
                        HStack(spacing: 4) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(post.isLiked ? .red : .gray)
                            
                            Text("\(post.likes)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 280)
        .background(.accent3)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ContentPostCard: View {
    let post: ContentPost
    let likeAction: () -> Void
    
    var body: some View {
        Button(action: {
            // In a real app, this would open the content link
            print("Open link: \(post.link)")
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Circle()
                        .fill(post.type.displayName == "Podcast" ? Color.purple : 
                             post.type.displayName == "Movie" ? Color.blue :
                             post.type.displayName == "Article" ? Color.green :
                             post.type.displayName == "News" ? Color.orange : Color.red)
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
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(post.postDate, style: .relative)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Button(action: likeAction) {
                                HStack(spacing: 4) {
                                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(post.isLiked ? .red : .gray)
                                    
                                    Text("\(post.likes)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
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
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
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
