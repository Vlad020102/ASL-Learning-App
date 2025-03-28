//
//  ServerErrorResponse.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 15.03.2025.
//
// MARK: - Network Error Types

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case encodingError(Error)
    
    var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .requestFailed(let error):
                return "Request failed: \(error.localizedDescription)"
            case .noData:
                return "No data received"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .serverError(let statusCode, let message):
                if let message = message {
                    return "Server error (\(statusCode)): \(message)"
                } else {
                    return "Server error (\(statusCode))"
                }
            case .encodingError(let error):
                return "Failed to encode request: \(error.localizedDescription)"
            }
        }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

