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
    
    private var chatsFileURL: URL {
        documentsDirectory.appendingPathComponent(Constants.Files.chatsFileName)
    }
    
    var imagesDirectory: URL {
        documentsDirectory.appendingPathComponent(Constants.Files.imagesDirectoryName)
    }
    
    private init() {
        createImagesDirectoryIfNeeded()
    }
    
    // MARK: - Messages File URL
    
    private func messagesFileURL(for chatId: String) -> URL {
        documentsDirectory.appendingPathComponent(Constants.Files.messagesFileName(for: chatId))
    }
    
    // MARK: - Chat Persistence
    
    /// Load chats from local JSON file, or create default chat if none exist
    /// - Returns: Array of chats
    func loadOrCreateDefaultChats() -> [Chat] {
        // Try to load existing chats
        if let chats = loadChats(), !chats.isEmpty {
            return chats
        }
        
        // Create default chat
        let defaultChat = Chat(
            id: Constants.DefaultChat.id,
            label: Constants.DefaultChat.label,
            createdAt: Date()
        )
        
        // Save and return
        try? saveChats([defaultChat])
        return [defaultChat]
    }
    
    /// Save chats to local JSON file
    func saveChats(_ chats: [Chat]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(chats)
        try data.write(to: chatsFileURL, options: [.atomicWrite])
        
        print("[PersistenceService] Saved \(chats.count) chats to disk")
    }
    
    /// Load chats from local JSON file
    func loadChats() -> [Chat]? {
        guard fileManager.fileExists(atPath: chatsFileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: chatsFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Chat].self, from: data)
        } catch {
            print("[PersistenceService] Error loading chats: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Create a new chat and add to storage
    func createChat(label: String) -> Chat {
        var chats = loadChats() ?? []
        
        let newChat = Chat(
            id: UUID().uuidString,
            label: label,
            createdAt: Date()
        )
        
        chats.append(newChat)
        try? saveChats(chats)
        
        return newChat
    }
    
    // MARK: - Message Persistence
    
    /// Save messages for a specific chat
    func saveMessages(_ messages: [Message], for chatId: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(messages)
        try data.write(to: messagesFileURL(for: chatId), options: [.atomicWrite])
        
        print("[PersistenceService] Saved \(messages.count) messages for chat \(chatId)")
    }
    
    /// Load messages for a specific chat
    func loadMessages(for chatId: String) -> [Message] {
        let fileURL = messagesFileURL(for: chatId)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("[PersistenceService] No messages file found for chat \(chatId)")
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let messages = try decoder.decode([Message].self, from: data)
            print("[PersistenceService] Loaded \(messages.count) messages for chat \(chatId)")
            return messages
        } catch {
            print("[PersistenceService] Error loading messages: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Check if messages file exists for a chat
    func hasPersistedMessages(for chatId: String) -> Bool {
        fileManager.fileExists(atPath: messagesFileURL(for: chatId).path)
    }
    
    /// Delete messages for a specific chat
    func deleteMessages(for chatId: String) throws {
        let fileURL = messagesFileURL(for: chatId)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("[PersistenceService] Deleted messages for chat \(chatId)")
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

