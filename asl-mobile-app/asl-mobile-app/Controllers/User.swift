import Foundation

struct User: Codable {
    
    let username: String
    let email: String
    let source: String
    let dailyGoal: Int
    let learningReason: String
    let level: Int
    let questionsAnsweredTotal: Int
    let questionsAnsweredToday: Int
    let streak: Int
    let createdAt: Date
    let updatedAt: Date
    let badges: [Badge]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        source = try container.decode(String.self, forKey: .source)
        dailyGoal = try container.decode(Int.self, forKey: .dailyGoal)
        learningReason = try container.decode(String.self, forKey: .learningReason)
        level = try container.decode(Int.self, forKey: .level)
        questionsAnsweredTotal = try container.decode(Int.self, forKey: .questionsAnsweredTotal)
        questionsAnsweredToday = try container.decode(Int.self, forKey: .questionsAnsweredToday)
        streak = try container.decode(Int.self, forKey: .streak)
        badges = try container.decode([Badge].self, forKey: .badges)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date format incorrect")
        }

        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .updatedAt, in: container, debugDescription: "Date format incorrect")
        }
    }
}

extension NetworkService {
    func getUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        
        self.request(
            endpoint: "users/\(id)",
            method: .get
        ) { (result: Result<User, NetworkError>) in
            switch result {
            case .success(let user):
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchProfile(completion: @escaping (Result<User, NetworkError>) -> Void) {
        authenticatedRequest(endpoint: "users/profile", method: .get, completion: completion)
    }
        
    func updateProfile(with user: UpdateUser, completion: @escaping (Result<User, NetworkError>) -> Void) {
        authenticatedRequest(endpoint: "users/profile", method: .put, body: user, completion: completion)
    }
    
}

struct UpdateUser: Codable {
    let email: String
    let username: String
}
