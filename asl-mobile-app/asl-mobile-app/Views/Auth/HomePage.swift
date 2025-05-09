//
//  ContentView 2.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 18.02.2025.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
            NavigationStack {
                ZStack (alignment: .top){
                    Color.background
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
                        .foregroundColor(.accent3.opacity(0.3))
                    VStack{
                        
                        Spacer()
                    
                        VStack(){
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.background)
                            
                            Text("ASLearning")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.background)
                        }.offset(y: 80)
                        Image("illustration")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                        
                        VStack {
                            NavigationLink(destination: RegistrationView()) {
                                Text("GET STARTED")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.main)
                                    .foregroundColor(.textSecondary)
                                    .cornerRadius(10)
                                    .bold(true)
                            }.navigationBarBackButtonHidden(true)
                            NavigationLink(destination: LoginView()) {
                                Text("I ALREADY HAVE AN ACCOUNT")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .fontWeight(.bold)
                                    .foregroundColor(.textSecondary)
                                    .background(Color.background)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.main, lineWidth: 2)
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
        HomeView().environmentObject(AuthManager())
    }
}
