//
//  DateUtils.swift
//  asl-mobile-app
//
//  Created by "Vlad Achim, Vodafone" on 23.03.2025.
//
import Foundation

struct DateUtils {
    static let shared = DateUtils()
    private let formatter = DateFormatter()
    
    func convertISOStringToDate(isoDateString: String) -> Date? {
        // Method 1: Using ISO8601DateFormatter (iOS 10+)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: isoDateString) {
            return date
        }
        
        // Method 2: Fallback to DateFormatter if the above fails
        let backupFormatter = DateFormatter()
        backupFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        backupFormatter.locale = Locale(identifier: "en_US_POSIX")
        backupFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return backupFormatter.date(from: isoDateString)
    }
}
