//
//  Quiz.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 24.03.2025.
//
import Foundation
extension NetworkService {
    func getQuiz(completion: @escaping (Result<QuizResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "quizes",
            method: .get)
        { (result: Result<QuizResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func completeQuiz(data: CompleteQuizData, completion: @escaping (Result<CompleteQuizResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "quizes/complete-quiz",
            method: .patch,
            body: data)
        { (result: Result<CompleteQuizResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum QuizType: String, Codable {
    case Bubbles
    case Matching
    case AlphabetStreak
    
    func toString() -> String {
        switch self {
        case .Bubbles:
            return "Bubbles"
        case .Matching:
            return "Matching"
        case .AlphabetStreak:
            return "Alphabet"
        }
    }
}

enum QuizStatus: String, Codable {
    case Completed, InProgress, Failed, Locked
    
    func toString() -> String {
        rawValue
    }
}

protocol QuizCardDisplayable {
    var id: Int { get }
    var title: String { get }
    var type: QuizType { get }
    var status: QuizStatus { get }
    var score: Double { get }
    var livesRemaining: Int { get }
}

struct QuizResponse: Codable {
    let quizes: QuizData
}

struct QuizData: Codable {
    let bubblesQuizes: [BubblesQuizData]
    let matchingQuizes: [MatchingQuizData]
    let alphabetQuizes: [AlphabetQuizData]
}

struct BubblesQuizData: Codable, QuizCardDisplayable {
    let id: Int
    let title: String
    let type: QuizType
    let status: QuizStatus
    let score: Double
    let livesRemaining: Int
    let signs: [Sign]?
}

struct Sign: Codable {
    let id: Int
    let difficulty: String
    let s3Url: String
    let name: String
    let options: String?
    let meaning: String?
    let explanations: [String]?
}

struct CompleteQuizData: Codable {
    let quizID: Int
    let score: String
    let livesRemaining: Int
    let status: QuizStatus
}

struct CompleteQuizResponse: Codable {
    let status: String
}

struct MatchingQuizData: Codable, QuizCardDisplayable {
    let id: Int
    let title: String
    let type: QuizType
    let status: QuizStatus
    let score: Double
    let livesRemaining: Int
    let pairs: [MatchingPair]
}

struct AlphabetQuizData: Codable, QuizCardDisplayable {
    let id: Int
    let title: String
    let type: QuizType
    let status: QuizStatus
    let score: Double
    let livesRemaining: Int
    let signs: [Sign]?
}

struct MatchingPair: Codable {
    let signGif: String
    let text: String
    let matchIndex: Int
}

enum CompletionStatus: Codable {
    case Completed
    case Failed
}

struct CompleteExerciseData: Codable {
    let exerciseId: String
    let score: String
    let livesRemaining: Int
    let status: CompletionStatus
}

enum QuizTypeWrapper {
    case bubbles(BubblesQuizData)
    case matching(MatchingQuizData)
    case alphabet(AlphabetQuizData)
    
    var status: QuizStatus {
        switch self {
        case .bubbles(let quiz): return quiz.status
        case .matching(let quiz): return quiz.status
        case .alphabet(let quiz): return quiz.status
        }
    }
}
