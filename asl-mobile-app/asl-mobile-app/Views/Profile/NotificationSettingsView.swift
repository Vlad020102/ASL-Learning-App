//
//  NotificationSettingsView.swift
//  asl-mobile-app
//
//  Created for ASL-Learning-App
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var notificationsEnabled = true
    @State private var reminderTime = Date()
    @State private var showPermissionAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Notification Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textSecondary)
                .padding(.top)
            
            // Enable/disable notifications
            Toggle("Daily Reminders", isOn: $notificationsEnabled)
                .foregroundColor(AppColors.text)
                .padding()
                .background(AppColors.accent3)
                .cornerRadius(10)
                .onChange(of: notificationsEnabled) { newValue in
                    if newValue {
                        requestNotificationPermission()
                    } else {
                        NotificationService.shared.cancelAllNotifications()
                    }
                }
            
            // Time picker for notifications
            if notificationsEnabled {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Remind me at:")
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(AppColors.accent3)
                .cornerRadius(10)
            }
            
            Spacer()
            
            Button(action: {
                if notificationsEnabled {
                    // Get the hour and minute from the selected time
                    let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                    if let hour = components.hour, let minute = components.minute {
                        // Schedule notification at the selected time
                        NotificationService.shared.scheduleReminderIfNeeded(hour: hour, minute: minute)
                    }
                }
                
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .padding()
        .background(AppColors.background)
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Permission Required"),
                message: Text("Please enable notifications in your device settings to receive daily reminders."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            checkNotificationStatus()
            
            // Initialize the time picker to show the currently scheduled time
            initializeTimePicker()
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    private func initializeTimePicker() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            if let request = requests.first(where: { $0.identifier == "ASLDailyReminder" }),
               let trigger = request.trigger as? UNCalendarNotificationTrigger {
                
                // Get the hour and minute from the trigger
                let hour = trigger.dateComponents.hour ?? 18
                let minute = trigger.dateComponents.minute ?? 0
                
                // Create a date with those components
                var components = DateComponents()
                components.hour = hour
                components.minute = minute
                
                if let date = Calendar.current.date(from: components) {
                    DispatchQueue.main.async {
                        self.reminderTime = date
                    }
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        NotificationService.shared.requestNotificationPermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    showPermissionAlert = true
                    notificationsEnabled = false
                }
            }
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
