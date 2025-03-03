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
                    Color(fromInt: 0x11384a)
                        .ignoresSafeArea ()
                    Circle()
                        .scale(1.7)
                        .foregroundColor (.white.opacity (0.1))
                    Circle()
                        .scale (1.35)
                        .foregroundColor(.white.opacity(0.1))
                    VStack{
                        Spacer()
                        
                        VStack(){
                            Image(systemName: "hand.raised.app")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(fromInt: 0x2f9ccf))
                            
                            Text("ASLearning")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(fromInt: 0x2f9ccf))
                                .monospaced(true)
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
                            .foregroundColor(.white)
                            .monospaced(true)
                        
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                print("Get Started tapped")
                            }) {
                                Text("GET STARTED")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(fromInt: 0x2f9ccf))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .monospaced(true)
                            }
                            
                            Button(action: {
                                //load another view
                            }) {
                                Text("I ALREADY HAVE AN ACCOUNT")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .monospaced(true)
                                    .foregroundColor(.white)
                                    .underline(true)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }

                }}
                .navigationBarHidden (true)
            // Logo
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
