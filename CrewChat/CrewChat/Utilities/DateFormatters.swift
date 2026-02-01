//
//  DateFormatters.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation

enum DateFormatters {
    /// Time formatter for message timestamps (e.g., "10:30 AM")
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    /// Full date formatter (e.g., "Jan 30, 2026 at 2:30 PM")
    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()
    
    /// Smart timestamp formatting with relative time
    /// - "Just now" for < 1 min
    /// - "2 minutes ago" for recent
    /// - "Today at 2:30 PM"
    /// - "Yesterday at 5:45 PM"
    /// - Full date for older messages
    static func formatSmartTimestamp(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let now = Date()
        let calendar = Calendar.current
        
        let secondsAgo = now.timeIntervalSince(date)
        
        // Less than 1 minute ago
        if secondsAgo < 60 {
            return "Just now"
        }
        
        // Less than 60 minutes ago
        if secondsAgo < 3600 {
            let minutes = Int(secondsAgo / 60)
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        }
        
        // Today
        if calendar.isDateInToday(date) {
            return "Today at \(timeFormatter.string(from: date))"
        }
        
        // Yesterday
        if calendar.isDateInYesterday(date) {
            return "Yesterday at \(timeFormatter.string(from: date))"
        }
        
        // Within last 7 days - show day name
        if let daysAgo = calendar.dateComponents([.day], from: date, to: now).day, daysAgo < 7 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE 'at' h:mm a"
            return dayFormatter.string(from: date)
        }
        
        // Older messages - full date
        return fullDateFormatter.string(from: date)
    }
}
