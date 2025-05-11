//
//  AuthManager.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 18.03.2025.
//
import SwiftUI
import KeychainAccess

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private let keychain = Keychain(service: "com.bachelor.asl-mobile-app")
    private let tokenKey = "authToken"
    @Published var isAuthenticated = false
    @Published var isReferred: Bool = false
    
    init() {
        checkForExistingToken()
    }
    
    func checkForExistingToken() {
        do {
            if let token = try keychain.get(tokenKey), !token.isEmpty {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
        } catch {
            self.isAuthenticated = false
            print("Error checking token: \(error)")
        }
    }
    
    func setToken(with token: String) {
        do {
            try keychain.set(token, key: tokenKey)
            isAuthenticated = true
        } catch {
            print("Error saving token: \(error)")
        }
    }
    func getToken() -> String? {
        do {
            if let token = try keychain.get(tokenKey), !token.isEmpty {
                return token
            } else {
                return nil
            }
        } catch {
            print("Error retrieving token: \(error.localizedDescription)")
            return nil
        }
    }
    func removeToken() {
        do {
            try keychain.remove(tokenKey)
            isAuthenticated = false
            isReferred = false
        } catch {
            print("Error removing token: \(error)")
        }
    }
}
