//
//  LoginScreen.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 12.03.2025.
//
import SwiftUI
import KeychainAccess

struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isSecured: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            AppColors.background.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 20) {
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
                    
                    TextField("Email / Username", text: $viewModel.emailOrUsername)
                        .padding()
                        .background(AppColors.accent3)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.primary, lineWidth: 2)
                        )
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
                                .foregroundColor(AppColors.background)
                        }
                    }
                    
                    .padding()
                    .background(AppColors.accent3)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.primary, lineWidth: 2)
                    )
                    
                    // Error message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !viewModel.message.isEmpty {
                        Text(viewModel.message)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Login button
                    Button(action: {
                        viewModel.login(authManager: authManager)
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
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical)
                    
                
                    NavigationLink(destination: RegistrationScreen()) {
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
                .background(AppColors.background)
                .cornerRadius(20)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(AppColors.background)
                .imageScale(.large)
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitleDisplayMode(.inline)
    }
}


// LoginViewModel to handle login logic
class LoginViewModel: ObservableObject {
    @EnvironmentObject var authManager: AuthManager
    @Published var emailOrUsername = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var message = ""
    
    private let keychain = Keychain(service: "com.bachelor.asl-mobile-app")
    private let tokenKey = "authToken"
    

    
    func login(authManager: AuthManager) {
        isLoading = true
        errorMessage = ""
        
        NetworkService.shared.login(emailOrUsername: emailOrUsername, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    authManager.setToken(with: response.accessToken)
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        self?.errorMessage = networkError.localizedDescription.description
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
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
