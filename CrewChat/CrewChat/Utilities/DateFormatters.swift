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
    
    /// Format a timestamp (milliseconds since epoch) to time string
    static func formatTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        return timeFormatter.string(from: date)
    }
}
