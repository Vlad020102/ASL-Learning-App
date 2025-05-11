import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showStreakFreezeAnimation = false
    @Published var streakFreezePurchased = false
    
    var hasActiveStreakFreezeForToday: Bool {
        guard let freezes = user?.streakFreezes else { return false }
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        return freezes.contains { freeze in
            calendar.startOfDay(for: freeze.date) == todayStart
        }
    }
    
    let streakFreezePrice: Int = 10


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
    
    func buyStreakFreeze() {
        isLoading = true
        errorMessage = nil
        let data = BuyStreakFreezeData(price: streakFreezePrice)
        NetworkService.shared.buyStreakFreeze(data: data) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(_):
                    self?.loadProfile() // Reload profile to get updated money and streak freezes
                    self?.streakFreezePurchased = true
                    self?.showStreakFreezeAnimation = true
                case .failure(let error):
                    self?.errorMessage = "Purchase failed: \(error.localizedDescription)"
                }
            }
        }
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
            ZStack {
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
                                .padding(.horizontal)
                            
                            // Wrap StatisticsView to constrain its width
                            VStack {
                                StatisticsView(
                                    level: viewModel.user?.level ?? 0,
                                    levelProgress: viewModel.user?.level_progress ?? 0,
                                    questionsAnsweredTotal: viewModel.user?.questionsAnsweredTotal ?? 0,
                                    questionsAnsweredToday: viewModel.user?.questionsAnsweredToday ?? 0,
                                    streak: viewModel.user?.streak ?? 0,
                                    dailyGoal: viewModel.user?.dailyGoal ?? 5)
                            }
                            .padding(.horizontal)
                            
                            // Badges Section
                            SectionHeaderView(title: "Badges") {
                                NavigationLink(destination: AllBadgesView(badges: viewModel.user?.badges ?? [])) {
                                    Text("View all")
                                        .foregroundColor(.main)
                                        .font(.subheadline)
                                }
                            }
                            .padding(.horizontal)
                            
                            BadgesView(badges: completedBadges, title: "")
                                .padding(.horizontal)
                            
                            // Store Section
                            SectionHeaderView(title: "Store")
                                .padding(.horizontal)
                            
                            StoreSectionView(viewModel: viewModel)
                                .padding(.horizontal)
                            
                            // Settings Section
                            SectionHeaderView(title: "Settings")
                                .padding(.horizontal)
                            
                            // Notifications button
                            Button(action: {
                                showNotificationSettings = true
                            }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.accent1)
                                        .frame(width: 30)
                                    
                                    Text("Notifications")
                                        .foregroundColor(.alternative)
                                        .font(.headline)
                                        .bold(true)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.textSecondary)
                                }
                                .padding()
                                .background(.accent3)
                                .cornerRadius(10)
                                .padding(.horizontal)
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
                                    .padding(.horizontal)
                            }
                            Spacer(minLength: 20)
                        }
                    }
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
                        
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack{
                            Text("\(viewModel.user?.money ?? 0)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .toolbarBackground(Color.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                
                // Show streak freeze animation when purchase is successful
                if viewModel.showStreakFreezeAnimation {
                    StreakFreezeSuccessView(showAnimation: $viewModel.showStreakFreezeAnimation) {
                        // This is called when the animation is dismissed
                        viewModel.streakFreezePurchased = true
                    }
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
        }
    }
}

// New reusable section header view
struct SectionHeaderView: View {
    var title: String
    var trailingContent: (() -> AnyView)? = nil
    
    init(title: String) {
        self.title = title
        self.trailingContent = nil
    }
    
    init<T: View>(title: String, @ViewBuilder trailingContent: @escaping () -> T) {
        self.title = title
        self.trailingContent = { AnyView(trailingContent()) }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.alternative)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
            
            if let trailingContent = trailingContent {
                trailingContent()
            }
        }
        .padding(.top)
        .padding(.bottom, 8)
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

// Updated Store Section View
struct StoreSectionView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center) {
                Image(systemName: "snowflake")
                    .foregroundColor(.accent1)
                Text("Streak Freeze")
                    .foregroundColor(.alternative)
                    .font(.headline)
                    .bold(true)
                Spacer()
                Text("10")
                    .foregroundColor(.alternative)
                    .font(.headline)
                    .bold(true)
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
            }
            
            if viewModel.hasActiveStreakFreezeForToday {
                HStack(alignment: .center) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    Text("Streak Freeze active for today!")
                        .foregroundColor(.text)
                    Spacer()
                }
            } else {
                Button(action: {
                    viewModel.buyStreakFreeze()
                }) {
                    HStack {
                        Text("Buy")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background((viewModel.user?.money ?? 0) < viewModel.streakFreezePrice ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled((viewModel.user?.money ?? 0) < viewModel.streakFreezePrice || viewModel.isLoading)
            }
        }
        .padding()
        .background(.accent3)
        .cornerRadius(10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
