//
//  Constants.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation

enum Constants {
    /// File names for persistence
    enum Files {
        static let chatsFileName = "chats.json"
        static let imagesDirectoryName = "Images"
        
        /// Returns the messages file name for a specific chat
        static func messagesFileName(for chatId: String) -> String {
            return "\(chatId)_messages.json"
        }
    }
    
    /// Default chat configuration
    enum DefaultChat {
        static let id = "default-mumbai-trip"
        static let label = "Mumbai Trip"
    }
    
    /// UserDefaults keys
    enum UserDefaultsKeys {
        /// Returns the seed data loaded key for a specific chat
        static func hasLoadedSeedData(for chatId: String) -> String {
            return "hasLoadedSeedData_\(chatId)"
        }
    }
}
