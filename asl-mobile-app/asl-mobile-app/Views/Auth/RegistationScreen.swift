//
//  RegistrationViewModel.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 03.03.2025.
//


import SwiftUI
import KeychainAccess

// Model to store user registration information
class RegistrationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var source: String = ""
    @Published var dailyGoal: Int = 10
    @Published var learningReason: String = ""
    @Published var experience: String = "Beginner"
    @Published var currentStep: Int = 1
    @Published var maxSteps: Int = 4
    @Published var showPassword: Bool = false
    @Published var showConfirmPassword: Bool = false
    @Published var errorMessage = ""
    
    
    var progressPercentage: Double {
        return Double(currentStep) / Double(maxSteps)
    }
    
    func register() {
        print("registering")
        let data: RegisterData = .init(
            email: self.email,
            username: self.username,
            password: self.password,
            confirmPassword: self.confirmPassword,
            source: self.source,
            dailyGoal: self.dailyGoal,
            learningReason: self.learningReason,
            experience: self.experience
        )
        
        NetworkService.shared.register(data:data){[weak self] result in DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    AuthManager.shared.setToken(with: response.accessToken)
                    print("Success: \(response)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            
            }
        }
    }
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    var isUsernameValid: Bool {
        return username.count >= 3
    }
        
    var isPasswordValid: Bool {
        return password.count >= 8
    }
    
    var doPasswordsMatch: Bool {
        return password == confirmPassword
    }
    
    var canProceedToNextStep: Bool {
        return isEmailValid && isUsernameValid && isPasswordValid && doPasswordsMatch
    }
}

struct RegistrationView: View {
    @StateObject private var registrationViewModel = RegistrationViewModel()
    @State private var navigateToHome = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            if navigateToHome {
                HomeView()
            } else {
                VStack {
                    // Progress indicator
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.disabledBackground)
                                .frame(width: geometry.size.width, height: 8)
                            
                            Rectangle()
                                .foregroundColor(.main)
                                .frame(width: geometry.size.width * registrationViewModel.progressPercentage, height: 8)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                    
                    // Current step view
                    switch registrationViewModel.currentStep {
                    case 1:
                        CredentialsView(registrationViewModel: registrationViewModel)
                    case 2:
                        SourceView(registrationViewModel: registrationViewModel)
                    case 3:
                        DailyGoalView(registrationViewModel: registrationViewModel)
                    case 4:
                        ReasonView(registrationViewModel: registrationViewModel)
                    case 5:
                        ExperienceView(registrationViewModel: registrationViewModel)
                    default:
                        Text("Error: Unknown step")
                    }
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        if registrationViewModel.currentStep < registrationViewModel.maxSteps {
                            withAnimation {
                                registrationViewModel.currentStep += 1
                            }
                        } else {
                            registrationViewModel.register()
                        }
                    }) {
                        Text("CONTINUE")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.main)
                            .foregroundColor(.textSecondary)
                            .bold(true)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            if registrationViewModel.currentStep > 1 {
                                withAnimation {
                                    registrationViewModel.currentStep -= 1
                                }
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.accent2)
                                .imageScale(.large)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        // Force hiding of back button with empty title
        .navigationTitle("")
    }
}


struct CredentialsView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create your account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
                .padding(.horizontal)
                .foregroundColor(.main)
            Spacer()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.accent3)
                        
                        TextField("Enter your email", text: $registrationViewModel.email)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        if !registrationViewModel.email.isEmpty && !registrationViewModel.isEmailValid {
                            Text("Please enter a valid email address")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Username Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(.accent3)
                        
                        TextField("Choose a username", text: $registrationViewModel.username)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                        
                        if !registrationViewModel.username.isEmpty && !registrationViewModel.isUsernameValid {
                            Text("Username must be at least 3 characters")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.accent3)
                        
                        HStack {
                            if registrationViewModel.showPassword {
                                TextField("Create a password", text: $registrationViewModel.password)
                                    .padding()
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Create a password", text: $registrationViewModel.password)
                                    .padding()
                                    .autocapitalization(.none)
                            }
                            
                            Button(action: {
                                registrationViewModel.showPassword.toggle()
                            }) {
                                Image(systemName: registrationViewModel.showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.accent1)
                            }
                            .padding(.trailing)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        if !registrationViewModel.password.isEmpty && !registrationViewModel.isPasswordValid {
                            Text("Password must be at least 8 characters")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Confirm Password")
                            .font(.headline)
                            .foregroundColor(.accent3)
                        
                        HStack {
                            if registrationViewModel.showConfirmPassword {
                                TextField("Confirm your password", text: $registrationViewModel.confirmPassword)
                                    .padding()
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Confirm your password", text: $registrationViewModel.confirmPassword)
                                    .padding()
                                    .autocapitalization(.none)
                            }
                            
                            Button(action: {
                                registrationViewModel.showConfirmPassword.toggle()
                            }) {
                                Image(systemName: registrationViewModel.showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.accent1)
                            }
                            .padding(.trailing)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        
                        if !registrationViewModel.confirmPassword.isEmpty && !registrationViewModel.doPasswordsMatch {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Step 1: How did you hear about us?
struct SourceView: View {
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
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
                .foregroundColor(.main)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sources, id: \.0) { source, icon in
                        Button(action: {
                            registrationViewModel.source = source
                        }) {
                            HStack {
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.accent1)
                                
                                Text(source)
                                    .font(.headline)
                                    .foregroundColor(.accent3)
                                
                                Spacer()
                                
                                if registrationViewModel.source == source {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accent1)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(
                                        registrationViewModel.source == source ?
                                        .secondary : Color.background
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
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
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
                        registrationViewModel.dailyGoal = minutes
                    }) {
                        HStack {
                            Text(name)
                                .font(.headline)
                                .foregroundColor(.accent3)
                            
                            Spacer()
                            
                            Text("\(minutes) min / day")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(registrationViewModel.dailyGoal == minutes ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    registrationViewModel.dailyGoal == minutes ?
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
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
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
                            registrationViewModel.learningReason = reason
                        }) {
                            HStack {
                                Text(reason)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if registrationViewModel.learningReason == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(
                                        registrationViewModel.learningReason == reason ?
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
    @ObservedObject var registrationViewModel: RegistrationViewModel
    
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
                        registrationViewModel.experience = level
                    }) {
                        HStack {
                            Text(level)
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if registrationViewModel.experience == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    registrationViewModel.experience == level ?
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

struct RegistrationFlow_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
