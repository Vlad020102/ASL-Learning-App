//
//  ProfileView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 19.03.2025.
//
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadProfile() {
        isLoading = true
        errorMessage = nil
        NetworkService.shared.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let userData):
                    self?.user = userData
                case .failure(let error):
                    self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
//    func saveProfile(completion: @escaping (Bool) -> Void) {
//        guard let _ = profile else {
//            errorMessage = "No profile data available"
//            completion(false)
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        let updateRequest = ProfileUpdateRequest(
//            username: username,
//            email: email
//        )
//
//        NetworkService.shared.updateProfile(with: updateRequest) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//
//                switch result {
//                case .success(let updatedProfile):
//                    self?.profile = updatedProfile
//                    completion(true)
//                case .failure(let error):
//                    self?.errorMessage = "Failed to update profile: \(error.localizedDescription)"
//                    completion(false)
//                }
//            }
//        }
//    }
    
    private func formatDate(_ dateString: String) -> String {
            let inputFormatter = ISO8601DateFormatter()
            if let date = inputFormatter.date(from: dateString) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .medium
                return outputFormatter.string(from: date)
            }
            return dateString
        }
}


struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel = ProfileViewModel()
    @State private var showEditProfileView: Bool = false
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading{
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage{
                        ErrorView(message: errorMessage)
                    } else {
                        ProfileHeaderView(username: viewModel.user?.username ?? "", email: viewModel.user?.email ?? "", createdAt: viewModel.user?.createdAt ?? Date())
                        StatisticsView(level: viewModel.user?.level ?? 0, questionsAnsweredTotal: viewModel.user?.questionsAnsweredTotal ?? 0, questionsAnsweredToday: viewModel.user?.questionsAnsweredToday ?? 0, streak: viewModel.user?.streak ?? 0, dailyGoal: viewModel.user?.dailyGoal ?? 5)
                        BadgesView(badges: viewModel.user?.badges ?? [])
                        Spacer(minLength: 20)
                        Button(action: {
                            AuthManager.shared.removeToken()
                        }) {
                            Text("LOGOUT")
                                .font(.headline)
                                .foregroundColor(AppColors.accent1)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                        Spacer(minLength: 20)
                    }
                }
                .padding(.horizontal)
            }
            .background(AppColors.background)
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
}

struct ProfileHeaderView: View {
    var username: String
    var email: String
    var createdAt: Date
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Profile")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "person.circle")
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 25, y: 25)
                }
                
                Text(username)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    Label {
                        Text(createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                    }
                }

            }
            .padding(.bottom, 16)
        }
        .background(AppColors.accent3)
        .cornerRadius(10)
        .padding(.bottom, 16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
