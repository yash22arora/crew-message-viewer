//
//  SeedDataLoader.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation

/// Loads predefined seed messages on first app launch
final class SeedDataLoader {
    
    static let shared = SeedDataLoader()
    
    private let userDefaults = UserDefaults.standard
    private let persistenceService = PersistenceService.shared
    
    private init() {}
    
    /// Load seed data if not already loaded
    /// - Returns: Array of seed messages if this is first launch, nil otherwise
    @discardableResult
    func loadSeedDataIfNeeded() -> [Message]? {
        guard !hasLoadedSeedData else {
            print("[SeedDataLoader] Seed data already loaded, skipping")
            return nil
        }
        
        let seedMessages = fetchSeedMessages()
        
        do {
            try persistenceService.saveMessages(seedMessages)
            markSeedDataAsLoaded()
            print("[SeedDataLoader] Successfully loaded \(seedMessages.count) seed messages")
            return seedMessages
        } catch {
            print("[SeedDataLoader] Error saving seed messages: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Check if seed data has been loaded previously
    var hasLoadedSeedData: Bool {
        userDefaults.bool(forKey: Constants.UserDefaultsKeys.hasLoadedSeedData)
    }
    
    /// Reset seed data flag (for testing)
    func resetSeedDataFlag() {
        userDefaults.set(false, forKey: Constants.UserDefaultsKeys.hasLoadedSeedData)
    }
    
    
    private func markSeedDataAsLoaded() {
        userDefaults.set(true, forKey: Constants.UserDefaultsKeys.hasLoadedSeedData)
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
