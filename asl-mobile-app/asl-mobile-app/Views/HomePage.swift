//
//  ContentView 2.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 18.02.2025.
//
import SwiftUI

struct HomePage: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
            NavigationView {
                ZStack (alignment: .top){
                    AppColors.accent2
                        .ignoresSafeArea ()
            
                    Circle()
                        .scale(2)
                        .foregroundColor (.white.opacity (0.1))
                    Circle()
                        .scale(1.7)
                        .foregroundColor (.white.opacity (0.1))
                    Circle()
                        .scale (1.35)
                        .foregroundColor(.white.opacity(0.1))
                    Circle()
                        .scale(1)
                        .foregroundColor(.white.opacity(0.1))
                    Circle()
                        .scale(0.65)
                        .foregroundColor(AppColors.accent3.opacity(0.3))
                    VStack{
                        
                        Spacer()
                    
                        VStack(){
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(AppColors.accent2)
                            
                            Text("ASLearning")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.accent2)
                        }.offset(y: 80)
                        Image("illustration")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                        
                        VStack {
                            NavigationLink(destination: RegistrationScreen().environmentObject(authManager)) {
                                Text("GET STARTED")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primary)
                                    .foregroundColor(AppColors.textSecondary)
                                    .cornerRadius(10)
                                    .bold(true)
                            }
                            NavigationLink(destination: LoginScreen().environmentObject(authManager)) {
                                Text("I ALREADY HAVE AN ACCOUNT")
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.accent3)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.accent2)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.primary, lineWidth: 2)
                                    )
                            }
                            
                        }
                        .padding(.horizontal, 20)
                        Spacer()
                    }
                    .offset(y: 100)
                }}
                .navigationBarHidden (true)
    }
}

struct Home_Preview: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
