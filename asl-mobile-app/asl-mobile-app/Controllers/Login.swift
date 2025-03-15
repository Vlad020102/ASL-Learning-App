//
//  LoginResponse.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 15.03.2025.
//
extension NetworkService {
    func login(emailOrUsername: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void)  {
        let loginData = LoginData(emailOrUsername: emailOrUsername, password: password)
        
        self.request(
            endpoint: "auth/login",
            method: .post,
            body: loginData
        ) { (result: Result<LoginResponse, NetworkError>) in
            print(result)
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct LoginResponse: Codable {
    let accessToken: String
    let user: User
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        
        let userDecoder = try container.superDecoder(forKey: .user)
        user = try User(from: userDecoder)
    }
    
}

struct LoginData: Codable {
    let emailOrUsername: String
    let password: String
}
