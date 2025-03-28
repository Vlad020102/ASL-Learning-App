//
//  Badge.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 28.03.2025.
//

import Foundation

struct Badge: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let icon: String
    let type: String
    let rarity: String
    let progress: Int
    let status: String
}
