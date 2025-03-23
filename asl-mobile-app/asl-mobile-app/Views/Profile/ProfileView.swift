//
//  ProfileView.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 19.03.2025.
//
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profile: ProfileResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var createdAt: Date = Date()
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var level: Int = 0
    @Published var dailyGoal: Int = 5
    @Published var streak: Int = 0
    @Published var questionsAnsweredTotal: Int = 0
    @Published var questionsAnsweredToday: Int = 0
    
    func loadProfile() {
        AuthManager.init().setToken(with: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImxvbCIsImlhdCI6MTc0Mjc0Mzc3MSwiZXhwIjoxNzQyNzQ3MzcxfQ.JDxEUKanhosBzpn0eT425JTIxC2gOplyzz-yKrlqN2o")
        isLoading = true
        errorMessage = nil
        
        NetworkService.shared.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let profileData):
                    self?.profile = profileData
                    self?.username = profileData.username
                    self?.email = profileData.email
                    self?.level = profileData.level
                    self?.questionsAnsweredTotal = profileData.questionsAnsweredTotal
                    self?.questionsAnsweredToday = profileData.questionsAnsweredToday
                    self?.streak = profileData.streak
                    self?.dailyGoal = profileData.dailyGoal
                    self?.createdAt = DateUtils.shared.convertISOStringToDate(isoDateString: profileData.createdAt) ?? Date()
                case .failure(let error):
                    self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func saveProfile(completion: @escaping (Bool) -> Void) {
        guard let _ = profile else {
            errorMessage = "No profile data available"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let updateRequest = ProfileUpdateRequest(
            username: username,
            email: email
        )
        
        NetworkService.shared.updateProfile(with: updateRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let updatedProfile):
                    self?.profile = updatedProfile
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                    completion(false)
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
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading{
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage{
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    } else {
                        ProfileHeaderView(username: viewModel.username, email: viewModel.email, createdAt: viewModel.createdAt)
                        StatisticsView(level: viewModel.level, questionsAnsweredTotal: viewModel.questionsAnsweredTotal, questionsAnsweredToday: viewModel.questionsAnsweredToday, streak: viewModel.streak, dailyGoal: viewModel.dailyGoal)
                        AchievementsView()
                        Spacer(minLength: 20)
                    }
                }
                .padding(.horizontal)
            }
            .background(AppColors.background)
            .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showEditProfileView = true
                        }) {
                            Text("Edit")
                        }
                    }
                }
            .sheet(isPresented: $showEditProfileView) {
                    AccountSettingsView()
                }
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
                    NavigationLink(destination: AccountSettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                    }
            
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

struct StatisticsView: View {
    var level: Int
    var questionsAnsweredTotal: Int
    var questionsAnsweredToday: Int
    var streak: Int
    var dailyGoal: Int
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                // Day streak stat
                StatCard(icon: "flame.fill", iconColor: .orange, value: String(questionsAnsweredTotal), label: "Total Questions Answered")
                
                // Total XP stat
                StatCard(icon: "bolt.fill", iconColor: .yellow, value: String(level), label: "Current Level")
            }
            
            HStack(spacing: 10) {
                // League stat
                ZStack(alignment: .topTrailing) {
                    StatCard(icon: "trophy.fill", iconColor: .yellow, value: "\(questionsAnsweredToday)/\(dailyGoal)", label: "Daily Goal")
                        .overlay(
                            Text("WEEK 1")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .cornerRadius(4)
                                .offset(y: -12),
                            alignment: .top
                        )
                }
                
                // Top 3 finishes stat
                StatCard(icon: "rosette", iconColor: .gray, value: String(streak), label: "Streak")
            }
        }
        .padding(.bottom, 16)
    }
}

struct StatCard: View {
    var icon: String
    var iconColor: Color
    var value: String
    var label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accent3)
        .cornerRadius(10)
    }
}

struct AchievementsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .foregroundColor(AppColors.secondary)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 4)
            
            // Wildfire achievement
            AchievementCard(
                title: "Wildfire",
                level: 1,
                progress: 1,
                total: 3,
                description: "Reach a 3 day streak",
                iconBackground: .red,
                iconSymbol: "flame.fill"
            )
            
            // Sage achievement
            AchievementCard(
                title: "Sage",
                level: 4,
                progress: 541,
                total: 1000,
                description: "Earn 1000 XP",
                iconBackground: .green,
                iconSymbol: "leaf.fill"
            )
            
            // Scholar achievement
            AchievementCard(
                title: "Scholar",
                level: 3,
                progress: 146,
                total: 175,
                description: "Learn 175 new words in a single course",
                iconBackground: .red,
                iconSymbol: "book.fill"
            )
            
            Button(action: {}) {
                Text("View all")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .padding(.top, 8)
        }
        .padding(.top, 8)
    }
}

struct AchievementCard: View {
    var title: String
    var level: Int
    var progress: Int
    var total: Int
    var description: String
    var iconBackground: Color
    var iconSymbol: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Achievement icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackground)
                    .frame(width: 56, height: 56)
                
                Image(systemName: iconSymbol)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("LEVEL \(level)")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(4)
                    .offset(y: 16)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(progress)/\(total)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: geometry.size.width * CGFloat(progress) / CGFloat(total), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(AppColors.accent3)
        .cornerRadius(10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
