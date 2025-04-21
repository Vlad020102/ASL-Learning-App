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
    let usedIn: [String]?
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
    let status: PhraseStatus
    let signs: [Sign]
}
enum PhraseStatus: String, Codable {
    case Available
    case Purchased
    case Finished
    
    func toString() -> String {
        switch self {
        case .Available:
            return "Available"
        case .Purchased:
            return "Purchased"
        case .Finished:
            return "Finished"
        }
    }
}

struct PurchasePhraseData: Codable {
    let status: String
    let price: Int
}


struct WikiResponse: Codable {
    let phrases: [Phrase]
    let signs: [Sign]
    let money: Int
}

extension NetworkService {
    func fetchPhrases(completion: @escaping (Result<WikiResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "phrases",
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
    
    func purchasePhrase(id: Int, data: PurchasePhraseData, completion: @escaping (Result<Phrase, Error>) -> Void) {
            authenticatedRequest(
                endpoint: "phrases/purchase/\(id)",
                method: .post,
                body: data)
            { (result: Result<Phrase, NetworkError>) in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
}
