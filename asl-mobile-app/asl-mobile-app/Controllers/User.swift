import Foundation

struct User: Codable {
    
    let username: String
    let email: String
    let createdAt: Date
    let updatedAt: Date
    

    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            username = try container.decode(String.self, forKey: .username)
            email = try container.decode(String.self, forKey: .email)
            
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
    
}
