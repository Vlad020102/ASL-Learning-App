//
//  Server.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 12.03.2025.
//
import SwiftUI

class Server {
    static let shared = Server()
    private let baseURL = "http://127.0.0.1:3001"
    
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void)  {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create request body
        let body: LoginData = .init(username: email, password: password)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try? encoder.encode(body)
    
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let res = try decoder.decode(LoginResponse.self, from: data)
                completion(.success(res))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()

    }
    
    func register(email: String, password: String, name: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create request body
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "name": name
        ]
        
        // Convert body to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NetworkError.invalidRequestBody))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    func get<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}

// Error types for network operations
enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidRequestBody
    case decodingError
}
struct LoginResponse: Codable {
    let accessToken: String
}
// User model
struct User: Codable {
    let username: String
    let name: String
    // Add other user properties as needed
}

struct LoginData: Codable {
    let username: String
    let password: String
}
