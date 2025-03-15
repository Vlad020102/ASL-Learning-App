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
    
    var body: some View {
        ZStack {
            AppColors.accent2.opacity(0.9).ignoresSafeArea()
            
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
                                .foregroundColor(AppColors.accent2)
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
                .background(AppColors.accent2)
                .cornerRadius(20)
            }
            .padding(.horizontal)
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
    }
}


// LoginViewModel to handle login logic
class LoginViewModel: ObservableObject {
    @Published var emailOrUsername = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    @Published var message = ""
    
    private let keychain = Keychain(service: "com.bachelor.asl-mobile-app")
    private let tokenKey = "authToken"
    
    init(){
        checkForExistingToken()
    }
    
    func checkForExistingToken() {
        do {
            if let token = try keychain.get(tokenKey) {
                isLoggedIn = true
            } else {
                isLoggedIn = false
            }
        } catch {
            isLoggedIn = false
        }
    }
    
    func login() {
        isLoading = true
        errorMessage = ""
        
        NetworkService.shared.login(emailOrUsername: emailOrUsername, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let data):
                    do {
                        try self?.keychain.set(data.accessToken, key: self?.tokenKey ?? "")
                        self?.message = "Logged in successfully!"
                        self?.isLoggedIn = true
                    } catch{
                        self?.errorMessage = "Failed to save token: \(error.localizedDescription)"
                    }
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
    
    func logout() {
        do {
            try keychain.remove(tokenKey)
            isLoggedIn = false
        } catch {
            errorMessage = "Failed to logout: \(error.localizedDescription)"
        }
    }
        
    func getToken() -> String? {
        try? keychain.get(tokenKey)
    }
}


struct LoginScreen_Preview: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
