//
//  StreakCalendarView.swift
//  asl-mobile-app
//
//  Created by v1ad_ach1m on 01.04.2025.
//


import SwiftUI

struct StreakCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StreakCalendarViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Calendar days
                            ForEach(viewModel.calendarDays, id: \.self) { date in
                                if let date = date {
                                    let isStreak = viewModel.streakDays.contains { 
                                        Calendar.current.isDate($0, inSameDayAs: date)
                                    }
                                    
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .frame(width: 35, height: 35)
                                        .background(isStreak ? AppColors.accent1 : Color.clear)
                                        .foregroundColor(isStreak ? .white : .primary)
                                        .cornerRadius(17.5)
                                } else {
                                    Color.clear
                                        .frame(width: 35, height: 35)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Streak Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadStreakDays()
        }
    }
}

class StreakCalendarViewModel: ObservableObject {
    @Published var streakDays: [Date] = []
    @Published var isLoading = false
    @Published var calendarDays: [Date?] = []
    
    init() {
        generateCalendarDays()
    }
    
    func loadStreakDays() {
        isLoading = true
        NetworkService.shared.fetchStreaks{ [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    let dateFormatter = ISO8601DateFormatter()
                    self?.streakDays = response.streakDays.compactMap { 
                        dateFormatter.date(from: $0)
                    }
                case .failure(let error):
                    print("Error loading streak days: \(error)")
                }
            }
        }
    }
    
    private func generateCalendarDays() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 0
        
        calendarDays = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                calendarDays.append(date)
            }
        }
    }
}
