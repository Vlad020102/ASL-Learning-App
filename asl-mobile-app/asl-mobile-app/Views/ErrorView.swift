//
//  ErrorView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 28.03.2025.
//
import SwiftUI

struct ErrorView: View {
    var message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(AppColors.accent1)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.accent1)
            
            Text(message)
                .font(.body)
                .foregroundColor(AppColors.accent2)
                .multilineTextAlignment(.center)
            
            Button(action: {
                AuthManager.shared.removeToken()
            }) {
                Text("Try Again")
                    .foregroundColor(.white)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
