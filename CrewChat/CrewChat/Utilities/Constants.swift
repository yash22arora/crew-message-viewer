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
        static let messagesFileName = "messages.json"
        static let imagesDirectoryName = "Images"
    }
    
    /// UserDefaults keys
    enum UserDefaultsKeys {
        static let hasLoadedSeedData = "hasLoadedSeedData"
    }
}
