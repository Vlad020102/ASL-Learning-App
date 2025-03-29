//
//  Quiz.swift
//  asl-mobile-app
//
//  Created by Rares Achim on 24.03.2025.
//

extension NetworkService {
    func getQuiz(completion: @escaping (Result<QuizResponse, Error>) -> Void) {
        authenticatedRequest(
            endpoint: "quizes",
            method: .get)
        { (result: Result<QuizResponse, NetworkError>) in
            print(result)
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
    /*Matching, VideoText, VideoAudio, AlphabetStreak*/
    // Can add more types in the future like image, text, etc.
    func toString() -> String {
        switch self {
        case .Bubbles:
            return "Bubbles"
        }
    }
}

enum QuizStatus: String, Codable {
    case Completed, InProgress, Failed, Locked
    
    func toString() -> String {
        switch self {
        case .Completed:
            return "Completed"
        case .InProgress:
            return "InProgress"
        case .Failed:
            return "Failed"
        case .Locked:
            return "Locked"
        }
    }
}


struct QuizResponse: Codable {
    let quizes: [QuizData]

}

struct QuizData: Codable {
    let id: Int
    let title: String
    let type: QuizType
    let status: QuizStatus
    let signs: [Sign]?
    let score: Double
    let livesRemaining: Int
}

struct Sign: Codable {
    let id: Int
    let difficulty: String
    let s3Url: String?
    let text: String
    let options: String?
}

struct CompleteQuizData: Codable {
    let quizId: Int
    let score: Double
    let livesRemaining: Int
    let status: QuizStatus
}

struct CompleteQuizResponse: Codable {
    let status: String
}
    
