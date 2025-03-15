//
//  RegistrationData.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 03.03.2025.
//


import SwiftUI

// Model to store user registration information
class RegistrationData: ObservableObject {
    @Published var source: String = ""
    @Published var dailyGoal: Int = 10
    @Published var learningReason: String = ""
    @Published var experience: String = "Beginner"
    @Published var currentStep: Int = 1
    @Published var maxSteps: Int = 4
    
    var progressPercentage: Double {
        return Double(currentStep) / Double(maxSteps)
    }
    
   
}

struct RegistrationFlow: View {
    @StateObject private var registrationData = RegistrationData()
    @State private var navigateToHome = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                if navigateToHome {
                    HomeView()
                } else {
                    VStack {
                        // Progress indicator
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .foregroundColor(AppColors.disabledBackground)
                                    .frame(width: geometry.size.width, height: 8)
                                
                                Rectangle()
                                    .foregroundColor(AppColors.primary)
                                    .frame(width: geometry.size.width * registrationData.progressPercentage, height: 8)
                            }
                            .clipShape(Capsule())
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                        
                        // Current step view
                        switch registrationData.currentStep {
                        case 1:
                            SourceView(registrationData: registrationData)
                        case 2:
                            DailyGoalView(registrationData: registrationData)
                        case 3:
                            ReasonView(registrationData: registrationData)
                        case 4:
                            ExperienceView(registrationData: registrationData)
                        default:
                            Text("Error: Unknown step")
                        }
                        
                        Spacer()
                        
                        // Continue button
                        Button(action: {
                            if registrationData.currentStep < registrationData.maxSteps {
                                withAnimation {
                                    registrationData.currentStep += 1
                                }
                            } else {
                                navigateToHome = true
                            }
                        }) {
                            Text("CONTINUE")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .foregroundColor(AppColors.textSecondary)
                                .bold(true)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .navigationBarItems(leading: 
                        Button(action: {
                            if registrationData.currentStep > 1 {
                                withAnimation {
                                    registrationData.currentStep -= 1
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                        }
                        .opacity(registrationData.currentStep > 1 ? 1.0 : 0.0)
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.accent2)
                    .imageScale(.large)
            })
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.accent2)
        }
    }
}

// Step 1: How did you hear about us?
struct SourceView: View {
    @ObservedObject var registrationData: RegistrationData
    
    let sources = [
        ("Friends/family", "person.2.fill"),
        ("TV", "tv.fill"),
        ("TikTok", "play.rectangle.fill"),
        ("News/article/blog", "newspaper.fill"),
        ("Facebook/Instagram", "globe"),
        ("Google Search", "magnifyingglass"),
        ("YouTube", "play.rectangle.on.rectangle.fill"),
        ("Other", "ellipsis")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How did you hear about ASLearning?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding(.horizontal)
                .foregroundColor(AppColors.primary)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sources, id: \.0) { source, icon in
                        Button(action: {
                            registrationData.source = source
                        }) {
                            HStack {
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(AppColors.accent1)
                                
                                Text(source)
                                    .font(.headline)
                                    .foregroundColor(AppColors.accent3)
                                
                                Spacer()
                                
                                if registrationData.source == source {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.accent1)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(
                                        registrationData.source == source ? 
                                        AppColors.secondary : AppColors.accent2
                                    )
                            )
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
    }
}

// Step 2: Choose a daily goal
struct DailyGoalView: View {
    @ObservedObject var registrationData: RegistrationData
    
    let goals = [
        ("Casual", 5),
        ("Regular", 10),
        ("Serious", 15),
        ("Intense", 20)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Great. Now choose a daily goal.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(goals, id: \.0) { name, minutes in
                    Button(action: {
                        registrationData.dailyGoal = minutes
                    }) {
                        HStack {
                            Text(name)
                                .font(.headline)
                                .foregroundColor(AppColors.accent3)
                            
                            Spacer()
                            
                            Text("\(minutes) min / day")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(registrationData.dailyGoal == minutes ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    registrationData.dailyGoal == minutes ? 
                                    Color.blue.opacity(0.1) : Color.white
                                )
                        )
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .padding(.top, 20)
        }
    }
}

// Step 3: Why are you learning ASL?
struct ReasonView: View {
    @ObservedObject var registrationData: RegistrationData
    
    let reasons = [
        "For work or school",
        "To communicate with friends/family",
        "I'm Deaf/Hard of Hearing",
        "I'm interested in Deaf culture",
        "To challenge myself",
        "For fun"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Why are you learning ASL?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: {
                            registrationData.learningReason = reason
                        }) {
                            HStack {
                                Text(reason)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if registrationData.learningReason == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(
                                        registrationData.learningReason == reason ? 
                                        Color.blue.opacity(0.1) : Color.white
                                    )
                            )
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
    }
}

// Step 4: What's your ASL experience?
struct ExperienceView: View {
    @ObservedObject var registrationData: RegistrationData
    
    let experienceLevels = [
        "Beginner",
        "Some basics",
        "Intermediate",
        "Advanced"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's your ASL experience?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(experienceLevels, id: \.self) { level in
                    Button(action: {
                        registrationData.experience = level
                    }) {
                        HStack {
                            Text(level)
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if registrationData.experience == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    registrationData.experience == level ? 
                                    Color.blue.opacity(0.1) : Color.white
                                )
                            )
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .padding(.top, 20)
        }
    }
}

// Placeholder for the Home view after registration
struct HomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to ASLearning!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Registration complete. Your learning journey begins now!")
                .multilineTextAlignment(.center)
                .padding()
            
            Image(systemName: "hand.wave.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding()
        }
    }
}

struct RegistrationFlow_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationFlow()
    }
}
