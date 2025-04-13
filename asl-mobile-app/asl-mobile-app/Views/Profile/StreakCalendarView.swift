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
                    VStack(spacing: 10) {
                        // Current streak indicator
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.accent1)
                            Text("\(viewModel.currentStreak) day streak")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.top)
                        
                        // Month navigation
                        HStack {
                            Button(action: {
                                viewModel.navigateMonth(forward: false)
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(viewModel.currentMonthYear)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.navigateMonth(forward: true)
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Day headers
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 35, height: 30)
                            }
                            
                            // Calendar days
                            ForEach(viewModel.calendarDays, id: \.id) { day in
                                if let date = day.date {
                                    Text("\(Calendar.current.component(.day, from: date))")
                                        .frame(width: 35, height: 35)
                                        .background(
                                            ZStack {
                                                // Background for streak days or answered days
                                                if day.isStreak {
                                                    Circle()
                                                        .fill(.accent1)
                                                        .frame(width: 35, height: 35)
                                                } else if day.isAnswered {
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.5))
                                                        .frame(width: 35, height: 35)
                                                }
                                                if day.isToday {
                                                    Circle()
                                                        .stroke(Color.yellow, lineWidth: 2)
                                                        .frame(width: 35, height: 35)
                                                }
                                            }
                                        )
                                        .foregroundColor(day.isStreak || day.isAnswered ? .white : day.isCurrentMonth ? .white : .gray)
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
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            viewModel.loadStreakDays()
        }
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    var isToday: Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
    let isStreak: Bool
    let isCurrentMonth: Bool
    let isAnswered: Bool // Added property for non-streak answered days
}

class StreakCalendarViewModel: ObservableObject {
    @Published var streakDays: [Date] = []
    @Published var answeredDays: [Date] = [] // Added to track answered but non-streak days
    @Published var isLoading = false
    @Published var calendarDays: [CalendarDay] = []
    @Published var currentStreak: Int = 0
    @Published var currentMonth: Date = Date()
    
    var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    init() {
        generateCalendarDays()
    }
    
    func loadStreakDays() {
        isLoading = true
        NetworkService.shared.fetchStreaks { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.currentStreak = response.currentStreak
                    
                    // Process calendar data
                    var allStreakDays: [Date] = []
                    var allAnsweredDays: [Date] = [] // Track all answered days
                    let calendar = Calendar.current
                    let currentYear = calendar.component(.year, from: Date())
                    
                    // Map month names to month numbers
                    let months = ["january": 1, "february": 2, "march": 3, "april": 4, "may": 5, "june": 6,
                                  "july": 7, "august": 8, "september": 9, "october": 10, "november": 11, "december": 12]
                    
                    for (monthName, days) in response.calendar {
                        if let monthNumber = months[monthName.lowercased()],
                           !days.isEmpty {
                            for day in days {
                                var dateComponents = DateComponents()
                                dateComponents.year = currentYear
                                dateComponents.month = monthNumber
                                dateComponents.day = day

                                if let date = calendar.date(from: dateComponents) {
                                    // Add all days to answered days
                                    allAnsweredDays.append(date)
                                    
                                    // Check if the date is part of the current streak
                                    let today = Date()
                                    let daysBetween = calendar.dateComponents([.day], from: date, to: today).day ?? Int.max
                                    
                                    // Only add days that are part of the current streak sequence
                                    if daysBetween < response.currentStreak {
                                        allStreakDays.append(date)
                                    }
                                }
                            }
                        }
                    }
                    
                    self?.streakDays = allStreakDays
                    self?.answeredDays = allAnsweredDays
                    self?.generateCalendarDays()
                    
                case .failure(let error):
                    print("Error loading streak days: \(error)")
                }
            }
        }
    }
    
    func navigateMonth(forward: Bool) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: forward ? 1 : -1, to: currentMonth) {
            currentMonth = newMonth
            generateCalendarDays()
        }
    }
    
    private func generateCalendarDays() {
        let calendar = Calendar.current
            
        // Get the first day of the current month view
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            
        // Get the weekday of the first day (1 = Sunday, 2 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
            
        // Get the number of days in the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)?.count ?? 0
            
        // Create calendar grid
        var days: [CalendarDay] = []
            
        // Add days from the previous month
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 0
            
        for i in 1..<firstWeekday {
            _ = daysInPreviousMonth - firstWeekday + i + 1
            if let date = calendar.date(byAdding: .day, value: -firstWeekday + i, to: startOfMonth) {
                let isStreakDay = streakDays.contains { calendar.isDate($0, inSameDayAs: date) }
                let isAnsweredDay = answeredDays.contains { calendar.isDate($0, inSameDayAs: date) }
                days.append(CalendarDay(date: date, isStreak: isStreakDay, isCurrentMonth: false, isAnswered: isAnsweredDay))
            }
        }
            
        // Add days of the current month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let isStreakDay = streakDays.contains { calendar.isDate($0, inSameDayAs: date) }
                let isAnsweredDay = answeredDays.contains { calendar.isDate($0, inSameDayAs: date) }
                days.append(CalendarDay(date: date, isStreak: isStreakDay, isCurrentMonth: true, isAnswered: isAnsweredDay))
            }
        }
            
        // Calculate remaining cells to fill a complete grid (6 rows of 7 days = 42 cells)
        let remainingDays = 42 - days.count
            
        // Add days from the next month to complete the grid
        for i in 1...remainingDays {
            if let lastDayOfMonth = calendar.date(byAdding: .day, value: daysInMonth - 1, to: startOfMonth),
               let date = calendar.date(byAdding: .day, value: i, to: lastDayOfMonth) {
                let isStreakDay = streakDays.contains { calendar.isDate($0, inSameDayAs: date) }
                let isAnsweredDay = answeredDays.contains { calendar.isDate($0, inSameDayAs: date) }
                days.append(CalendarDay(date: date, isStreak: isStreakDay, isCurrentMonth: false, isAnswered: isAnsweredDay))
            }
        }
            
        calendarDays = days
    }
}
