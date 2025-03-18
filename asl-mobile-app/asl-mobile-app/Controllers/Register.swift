//
//  LoginResponse.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 15.03.2025.
//
extension NetworkService {
    func register(data: RegisterData, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        self.request(
            endpoint: "auth/register",
            method: .post,
            body: data
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

struct RegisterData: Codable {
    let email: String
    let username: String
    let password: String
    let confirmPassword: String
    let source: String?
    let dailyGoal: Int?
    let learningReason: String?
    let experience: String?
}
