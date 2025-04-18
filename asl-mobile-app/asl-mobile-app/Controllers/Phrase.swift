//
//  Phrase.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 15.04.2025.
//

struct Sign: Codable {
    let id: Int
    let name: String
    let difficulty: String
    let s3Url: String

    let meaning: String?
    let options: String?
    let explanations: [String]?
}

struct Phrase: Codable {
    let id: Int
    let name: String
    let translation: String
    let difficulty: Int // 1-5
    
    let price: Int
    var isPurchased: Bool
    var signs: [Sign]
}

struct WikiResponse: Codable {
    let phrases: [Phrase]
    let signs: [Sign]
}

extension NetworkService {
    func fetchPhrases(completion: @escaping (Result<WikiResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "quizes",
            method: .get)
        { (result: Result<WikiResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
