import Foundation

struct User: Codable {
    
    let username: String
    let email: String
    let source: String
    let dailyGoal: Int
    let learningReason: String
    let level: Int
    let level_progress: Double
    let questionsAnsweredTotal: Int
    let questionsAnsweredToday: Int
    let streak: Int
    let streakFreezes: [StreakFreezes]?
    let createdAt: Date
    let updatedAt: Date
    let referralCode: String
    let badges: [Badge]
    let money: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        source = try container.decode(String.self, forKey: .source)
        dailyGoal = try container.decode(Int.self, forKey: .dailyGoal)
        learningReason = try container.decode(String.self, forKey: .learningReason)
        level = try container.decode(Int.self, forKey: .level)
        level_progress = try container.decode(Double.self, forKey: .level_progress)
        questionsAnsweredTotal = try container.decode(Int.self, forKey: .questionsAnsweredTotal)
        questionsAnsweredToday = try container.decode(Int.self, forKey: .questionsAnsweredToday)
        streak = try container.decode(Int.self, forKey: .streak)
        referralCode = try container.decode(String.self, forKey: .referralCode)
        badges = try container.decode([Badge].self, forKey: .badges)
        streakFreezes = try? container.decode([StreakFreezes].self, forKey: .streakFreezes)
        money = try? container.decode(Int.self, forKey: .money)
        
        
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

struct Badge: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let icon: String
    let type: String
    let rarity: String
    let progress: Int
    let status: String
    let target: Int
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
        
    func fetchStreaks(completion: @escaping (Result<StreakData, NetworkError>) -> Void) {
        authenticatedRequest(endpoint: "users/streaks", method: .get, completion: completion)
    }
    
    func buyStreakFreeze(data: BuyStreakFreezeData, completion: @escaping (Result<[StreakFreezes], NetworkError>) -> Void) {
        print(data)
        authenticatedRequest(
            endpoint: "users/buy-streak-freeze",
            method: .post,
            body: data)
        { (result: Result<[StreakFreezes], NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

struct StreakData: Codable {
    let calendar: [String: [Int]]
    let currentStreak: Int
}

struct StreakFreezes: Codable {
    let id: Int
    let date: Date
}

struct BuyStreakFreezeData: Codable {
    let price: Int
}
