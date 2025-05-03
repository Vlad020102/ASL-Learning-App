//
//  ErrorView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 28.03.2025.
//
import SwiftUI

struct ErrorView: View {
    var message: String
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.accent1)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.accent1)
            
            Text(message)
                .font(.body)
                .foregroundColor(.accent2)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Try Again")
                    .foregroundColor(.white)
                    .padding()
                    .background(.main)
                    .cornerRadius(10)
            }
            Button(action: {
                AuthManager.shared.removeToken()
            }) {
                Text("LOGOUT")
                    .font(.headline)
                    .foregroundColor(.accent1)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.red, lineWidth: 1)
                    )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}
