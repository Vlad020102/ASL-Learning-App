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
    @State private var showNotificationSettings: Bool = false
    
    var completedBadges: [Badge] {
        return (viewModel.user?.badges ?? []).filter { $0.status == "Completed" }
    }
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading{
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage{
                        ErrorView(message: errorMessage, retryAction: {
                            viewModel.loadProfile()
                        })
                    } else {
                        ProfileHeaderView(username: viewModel.user?.username ?? "", email: viewModel.user?.email ?? "", createdAt: viewModel.user?.createdAt ?? Date())
                        StatisticsView(
                            level: viewModel.user?.level ?? 0,
                            levelProgress: viewModel.user?.level_progress ?? 0,
                            questionsAnsweredTotal: viewModel.user?.questionsAnsweredTotal ?? 0, questionsAnsweredToday: viewModel.user?.questionsAnsweredToday ?? 0, streak: viewModel.user?.streak ?? 0,
                            dailyGoal: viewModel.user?.dailyGoal ?? 5)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Badges")
                                    .foregroundColor(.alternative)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllBadgesView(badges: viewModel.user?.badges ?? [])) {
                                    Text("View all")
                                        .foregroundColor(.main)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            BadgesView(badges: completedBadges, title: "")
                        }
                        
                        // Add settings section
                        VStack(alignment: .leading) {
                            Text("Settings")
                                .foregroundColor(.alternative)
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Notifications settings
                            Button(action: {
                                showNotificationSettings = true
                            }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.accent1)
                                        .frame(width: 30)
                                    
                                    Text("Notifications")
                                        .foregroundColor(.text)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.textSecondary)
                                }
                                .padding()
                                .background(.accent3)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Spacer(minLength: 20)
                        Button(action: {
                            AuthManager.shared.removeToken()
                        }) {
                            Text("LOGOUT")
                                .font(.headline)
                                .foregroundColor(.accent1)
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
            .background(Color.background)
            .onAppear {
                viewModel.loadProfile()
            }
            .sheet(isPresented: $showNotificationSettings) {
                NotificationSettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                
                        .foregroundColor(.textSecondary)
                }
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
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 1)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .center) // Centers the line

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
        .background(.accent3)
        .cornerRadius(10)
        .padding(.bottom, 16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
