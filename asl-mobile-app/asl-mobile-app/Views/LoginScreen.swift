//
//  LoginScreen.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 12.03.2025.
//
import SwiftUI

struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isSecured: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.accent2.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo and app name
                VStack {
                    Image(systemName: "hand.raised.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(AppColors.primary)
                    
                    Text("ASLearning")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                // Login form
                VStack(spacing: 20) {
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Email field
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(AppColors.primary.opacity(0.2))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    // Password field
                    HStack {
                        if isSecured {
                            SecureField("Password", text: $viewModel.password)
                        } else {
                            TextField("Password", text: $viewModel.password)
                        }
                        
                        Button(action: {
                            isSecured.toggle()
                        }) {
                            Image(systemName: isSecured ? "eye.slash" : "eye")
                                .foregroundColor(AppColors.accent3)
                        }
                    }
                    .padding()
                    .background(AppColors.selectedBackground)
                    .cornerRadius(10)
                    
                    // Error message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Login button
                    Button(action: {
                        viewModel.login()
                    }) {
                        ZStack {
                            Text("LOGIN")
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(10)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.textSecondary))
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    // Forgot password link
                    Button(action: {
                        // Action for forgot password
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(AppColors.accent3)
                            .underline()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical)
                    
                
                    NavigationLink(destination: RegistrationFlow()) {
                        Text("CREATE NEW ACCOUNT")
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.accent3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.selectedBackground)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 35)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(AppColors.accent3)
                .imageScale(.large)
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitleDisplayMode(.inline)
    }
}


// LoginViewModel to handle login logic
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    
    func login() {
        isLoading = true
        errorMessage = ""
        Server.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    print("Login successful for user: \(user.accessToken)")
                    self?.isLoggedIn = true
                    // You might want to store the user data or token here
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}


struct LoginScreen_Preview: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
