//
//  Server.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 12.03.2025.
//
//

import Foundation
import KeychainAccess

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    private let baseURL: String
    init(baseURL: String = "http://127.0.0.1:3001") {
        self.baseURL = baseURL
    }
    
    func request<T: Encodable, U: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil,
        headers: [String: String] = ["Content-Type": "application/json"],
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            let encoder = JSONEncoder()
            
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                completion(.failure(.encodingError(error)))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            let successRange = 200..<300
            guard successRange.contains(httpResponse.statusCode) else {
                if let data = data, !data.isEmpty {
                    do {
                        let errorResponse = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                        completion(.failure(.serverError(
                            statusCode: errorResponse.statusCode,
                            message: errorResponse.message.description
                        )))
                    } catch {
                        let message = String(data: data, encoding: .utf8)
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: message)))
                    }
                } else {
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: nil)))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date format incorrect")
                }
                
                let decodedResponse = try decoder.decode(U.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    struct EmptyBody: Encodable {}
    func request<U: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: [String: String] = ["Content-Type": "application/json"],
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        request(
            endpoint: endpoint,
            method: method,
            body: nil as EmptyBody?,
            headers: headers,
            completion: completion
        )
    }
    
    func authenticatedRequest<T: Encodable, U: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: T? = nil,
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        guard let token = AuthManager.init().getToken() else {
            completion(.failure(.serverError(statusCode: 401, message: "Authentication token not found")))
            return
        }
        print(token)
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        request(
            endpoint: endpoint,
            method: method,
            body: body,
            headers: headers,
            completion: completion
        )
    }
    
    func authenticatedRequest<U: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<U, NetworkError>) -> Void
    ) {
        authenticatedRequest(endpoint: endpoint, method: method, body: nil as EmptyBody?, completion: completion)
    }
}


struct ServerErrorResponse: Decodable {
    let message: ServerErrorMessage
    let error: String
    let statusCode: Int
    
    enum ServerErrorMessage: Decodable {
        case string(String)
        case stringArray([String])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let arrayValue = try? container.decode([String].self) {
                self = .stringArray(arrayValue)
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode message - neither String nor [String]"
                )
            }
        }
        
        var description: String {
            switch self {
            case .string(let message):
                return message
            case .stringArray(let messages):
                return messages.joined(separator: "\n")
            }
        }
    }
}

