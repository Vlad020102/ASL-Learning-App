//
//  LoginResponse.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 15.03.2025.
//

struct AuthResponse: Codable {
    let accessToken: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
    }
    
}

struct LoginData: Codable {
    let emailOrUsername: String
    let password: String
}

extension NetworkService {
    func login(emailOrUsername: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void)  {
        let loginData = LoginData(emailOrUsername: emailOrUsername, password: password)
        
        self.request(
            endpoint: "auth/login",
            method: .post,
            body: loginData
        ) { (result: Result<AuthResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
