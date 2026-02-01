//
//  SeedDataLoader.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation

/// Loads predefined seed messages on first app launch for the default chat
final class SeedDataLoader {
    
    static let shared = SeedDataLoader()
    
    private let userDefaults = UserDefaults.standard
    private let persistenceService = PersistenceService.shared
    
    private init() {}
    
    /// Load seed data for a specific chat if not already loaded
    /// Only seeds default chat (Constants.DefaultChat.id)
    /// - Parameter chatId: The chat ID to potentially seed
    /// - Returns: Array of seed messages if this is first launch for this chat, nil otherwise
    @discardableResult
    func loadSeedDataIfNeeded(for chatId: String) -> [Message]? {
        // Only seed the default chat
        guard chatId == Constants.DefaultChat.id else {
            print("[SeedDataLoader] Not default chat, skipping seed data")
            return nil
        }
        
        guard !hasLoadedSeedData(for: chatId) else {
            print("[SeedDataLoader] Seed data already loaded for chat \(chatId), skipping")
            return nil
        }
        
        let seedMessages = fetchSeedMessages()
        
        do {
            try persistenceService.saveMessages(seedMessages, for: chatId)
            markSeedDataAsLoaded(for: chatId)
            print("[SeedDataLoader] Successfully loaded \(seedMessages.count) seed messages for chat \(chatId)")
            return seedMessages
        } catch {
            print("[SeedDataLoader] Error saving seed messages: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Check if seed data has been loaded for a specific chat
    func hasLoadedSeedData(for chatId: String) -> Bool {
        userDefaults.bool(forKey: Constants.UserDefaultsKeys.hasLoadedSeedData(for: chatId))
    }
    
    /// Reset seed data flag for a specific chat (for testing)
    func resetSeedDataFlag(for chatId: String) {
        userDefaults.set(false, forKey: Constants.UserDefaultsKeys.hasLoadedSeedData(for: chatId))
    }
    
    private func markSeedDataAsLoaded(for chatId: String) {
        userDefaults.set(true, forKey: Constants.UserDefaultsKeys.hasLoadedSeedData(for: chatId))
    }
    
    private func fetchSeedMessages() -> [Message] {
        guard let url = Bundle.main.url(forResource: "SeedMessages", withExtension: "json") else {
            print("[SeedDataLoader] Error: SeedMessages.json not found in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let messages = try decoder.decode([Message].self, from: data)
            return messages
        } catch {
            print("[SeedDataLoader] Error decoding seed messages: \(error.localizedDescription)")
            return []
        }
    }
}

