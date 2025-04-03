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
                        .onChange(of: reminderTime) { newValue in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                            if let hour = components.hour, let minute = components.minute {
                                scheduleNotificationWithTime(hour: hour, minute: minute)
                            }
                        }
                }
                .padding()
                .background(AppColors.accent3)
                .cornerRadius(10)
            }
            
            Spacer()
            
            Button(action: {
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
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = (settings.authorizationStatus == .authorized)
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
    
    private func scheduleNotificationWithTime(hour: Int, minute: Int) {
        // Check user's conditions first
        NotificationService.shared.scheduleReminderIfNeeded(hour: hour, minute: minute)
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
