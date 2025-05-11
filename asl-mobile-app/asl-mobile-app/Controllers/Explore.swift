//
//  Explore.swift
//  asl-mobile-app
//
//  Created by vlad.achim on 11.05.2025.
//
struct ExploreResponse: Codable{
    let extras: Extra
    let referralCode: String?
}

struct Extra: Codable {
    let Article: [ExtraItem]?
    let Book: [ExtraItem]?
    let Event: [ExtraItem]?
    let Game: [ExtraItem]?
    let Movie: [ExtraItem]?
    let News: [ExtraItem]?
    let Podcast: [ExtraItem]?
}

struct ExtraItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageURL: String?
    let type: ExtraType
    let link: String
}

enum ExtraType: String, CaseIterable, Codable {
    case Podcast
    case Movie
    case Article
    case News
    case Event
    case Game
    case Book
    
    var icon: String {
        switch self {
            case .Podcast: return "music.microphone"
            case .Movie: return "film"
            case .Article: return "doc.text"
            case .News: return "newspaper"
            case .Event: return "calendar"
            case .Book: return "book"
            case .Game: return "gamecontroller"
        }
    }
    
    var displayName: String {
        return self.rawValue.capitalized
    }
}

extension NetworkService {
    func fetchExplore(completion: @escaping (Result<ExploreResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "explore",
            method: .get)
        { (result: Result<ExploreResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


