//
//  Profile.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 23.03.2025.
//

extension NetworkService {
    func fetchProfile(completion: @escaping (Result<ProfileResponse, NetworkError>) -> Void) {
        authenticatedRequest(endpoint: "users/profile", method: .get, completion: completion)
    }
        
    func updateProfile(with profileData: ProfileUpdateRequest, completion: @escaping (Result<ProfileResponse, NetworkError>) -> Void) {
        authenticatedRequest(endpoint: "users/profile", method: .put, body: profileData, completion: completion)
    }
}
struct ProfileResponse: Decodable {
    let username: String
    let email: String
    let source: String
    let dailyGoal: Int
    let learningReason: String
    let level: Int
    let questionsAnsweredTotal: Int
    let questionsAnsweredToday: Int
    let streak: Int
    let createdAt: String
    let updatedAt: String
    let badges: [String]
    

}

struct ProfileUpdateRequest: Encodable {
    let username: String
    let email: String
    // Add other fields that can be updated
}
