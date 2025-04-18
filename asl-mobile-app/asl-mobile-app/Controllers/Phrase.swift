//
//  Phrase.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 15.04.2025.
//

struct Sign: Codable, Identifiable {
    let id: Int
    let name: String
    let difficulty: String
    let s3Url: String

    let meaning: String
    let options: String?
    let description: String?
    let explanation: [String]?
}

struct Phrase: Codable {
    let id: Int
    let name: String
    let description: String
    let meaning: String
    let explanation: [String]?
    let difficulty: String
    let s3Url: String
    let price: Int
    let status: String
    
    let signs: [Sign]
}

struct WikiResponse: Codable {
    let phrases: [Phrase]
    let signs: [Sign]
}

extension NetworkService {
    func fetchPhrases(completion: @escaping (Result<WikiResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "phrases",
            method: .get)
        { (result: Result<WikiResponse, NetworkError>) in
            switch result {
            case .success(let response):
                print(response)
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
