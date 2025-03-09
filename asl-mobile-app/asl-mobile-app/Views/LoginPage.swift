//
//  ContentView 2.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 18.02.2025.
//
import SwiftUI

struct LoginPage: View {
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
                        .foregroundColor(AppColors.primary.opacity(0.3))
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
                            NavigationLink(destination: RegistrationFlow()) {
                                Text("GET STARTED")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primary)
                                    .foregroundColor(AppColors.textSecondary)
                                    .cornerRadius(10)
                                    .bold(true)
                            }
                            Button(action: {
                            
                            }) {
                                Text("I ALREADY HAVE AN ACCOUNT")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .bold(true)
                                    .cornerRadius(10)
                                    .underline(true)
                                    .foregroundColor(AppColors.accent3)
                                    .background(AppColors.selectedBackground)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
