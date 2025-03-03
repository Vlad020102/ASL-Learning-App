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
                        .scale(1.7)
                        .foregroundColor (.white.opacity (0.3))
                    Circle()
                        .scale (1.35)
                        .foregroundColor(.white.opacity(0.5))
                    VStack{
                        Spacer()
                        
                        VStack(){
                            Image(systemName: "hand.raised.app")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(AppColors.primary)
                            
                            Text("ASLearning")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primary)
                        }
                        .offset(y: 100)
                
                        
                        Image("illustration")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                        
                        Text("The free, fun, and effective way to learn \nAmerican Sign Language!")
                            .font(Font.system(size: 18, weight: .light))
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(AppColors.text)
                            .bold(true)
                        
                        Spacer()
                        
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
                                //load another view
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

                }}
                .navigationBarHidden (true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
