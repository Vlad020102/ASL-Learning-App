//
//  NotificationService.swift
//  asl-mobile-app
//
//  Created for ASL-Learning-App
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // Request permission for notifications
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    // Schedule daily reminder if conditions are met
    func scheduleReminderIfNeeded(hour: Int = 18, minute: Int = 0) {
        // First check if notifications are authorized
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized")
                return
            }
            
            // Create a notification content that will be updated with proper message later
            let content = UNMutableNotificationContent()
            content.title = "ASL Practice Reminder"
            content.body = "It's time to practice ASL today!"
            content.sound = UNNotificationSound.default
            
            // Set the notification to trigger at the specified time daily
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create the notification request with a custom identifier
            let identifier = "ASLDailyReminder"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Remove any existing notification with the same identifier
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            
            // Schedule the new notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Daily notification scheduled for \(hour):\(minute)")
                }
            }
        }
    }
    
    // Update notification content based on user data
    func updateNotificationContent() {
        guard AuthManager.shared.isAuthenticated else { return }
        
        let identifier = "ASLDailyReminder"
        
        // Get the current pending notification requests
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Find our daily reminder notification
            guard let reminderRequest = requests.first(where: { $0.identifier == identifier }),
                  let trigger = reminderRequest.trigger as? UNCalendarNotificationTrigger else {
                return
            }
            
            // Check user data to determine appropriate notification content
            NetworkService.shared.fetchProfile { result in
                switch result {
                case .success(let userData):
                    // Create updated notification content
                    let content = UNMutableNotificationContent()
                    
                    if userData.questionsAnsweredTotal == 0 {
                        content.title = "Keep your \(userData.streak) day streak going!"
                        content.body = "Don't break your streak! Practice ASL today."
                    } else {
                        return
                    }
                    
                    content.sound = UNNotificationSound.default
                    
                    // Create new request with updated content but same trigger
                    let newRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    
                    // Replace the existing notification
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                    UNUserNotificationCenter.current().add(newRequest) { error in
                        if let error = error {
                            print("Error updating notification: \(error.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    print("Error fetching user data for notification: \(error)")
                }
            }
        }
    }
    
    // Cancel all scheduled notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
