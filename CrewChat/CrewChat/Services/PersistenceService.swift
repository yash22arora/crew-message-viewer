//
//  PersistenceService.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation

/// Service responsible for persisting and loading messages from local JSON storage
final class PersistenceService {
    
    static let shared = PersistenceService()
    
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var messagesFileURL: URL {
        documentsDirectory.appendingPathComponent(Constants.Files.messagesFileName)
    }
    
    var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent(Constants.Files.imagesDirectoryName)
    }
    
    private init() {
        createImagesDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// Save messages to local JSON file
    /// - Parameter messages: Array of messages to save
    /// - Throws: Encoding or file write errors
    func saveMessages(_ messages: [Message]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(messages)
        try data.write(to: messagesFileURL, options: [.atomicWrite])
        
        print("[PersistenceService] Saved \(messages.count) messages to disk")
    }
    
    /// Load messages from local JSON file
    /// - Returns: Array of messages, or empty array if file doesn't exist
    func loadMessages() -> [Message] {
        guard fileManager.fileExists(atPath: messagesFileURL.path) else {
            print("[PersistenceService] No messages file found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: messagesFileURL)
            let decoder = JSONDecoder()
            let messages = try decoder.decode([Message].self, from: data)
            print("[PersistenceService] Loaded \(messages.count) messages from disk")
            return messages
        } catch {
            print("[PersistenceService] Error loading messages: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Check if messages file exists
    var hasPersistedMessages: Bool {
        fileManager.fileExists(atPath: messagesFileURL.path)
    }
    
    /// Delete all persisted messages (for testing/reset)
    func deleteAllMessages() throws {
        if fileManager.fileExists(atPath: messagesFileURL.path) {
            try fileManager.removeItem(at: messagesFileURL)
            print("[PersistenceService] Deleted messages file")
        }
    }
    
    // MARK: - Private Methods
    
    private func createImagesDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            do {
                try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
                print("[PersistenceService] Created Images directory")
            } catch {
                print("[PersistenceService] Error creating Images directory: \(error.localizedDescription)")
            }
        }
    }
}
