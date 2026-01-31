//
//  ChatViewModel.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for managing chat messages and state
final class ChatViewModel: ObservableObject {
    
    @Published private(set) var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var isAgentTyping: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let persistenceService: PersistenceService
    private let seedDataLoader: SeedDataLoader
    private let dataManager: ChatDataManaging
    
    init(persistenceService: PersistenceService = .shared,
         seedDataLoader: SeedDataLoader = .shared) {
        self.persistenceService = persistenceService
        self.seedDataLoader = seedDataLoader
        self.dataManager = ChatDataManager()
        
        loadMessages()
    }
    
    /// Load messages from persistence or seed data
    func loadMessages() {
        isLoading = true
        
        // First, try to load seed data if this is first launch
        if let seedMessages = seedDataLoader.loadSeedDataIfNeeded() {
            messages = seedMessages.sorted { $0.timestamp < $1.timestamp }
        } else {
            // Load from persistence
            messages = persistenceService.loadMessages().sorted { $0.timestamp < $1.timestamp }
        }
        
        isLoading = false
    }
    
    /// Send a new text message from the user
    /// - Parameter text: The message text
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message.textMessage(text.trimmingCharacters(in: .whitespacesAndNewlines), sender: .user)
        addMessage(newMessage)
        
        // Fetch agent response asynchronously
        fetchAgentResponse()
    }
    
    /// Add an image message from the user
    /// - Parameters:
    ///   - path: Local file path to the image
    ///   - size: File size in bytes
    ///   - caption: Optional caption for the image
    func sendImageMessage(path: String, size: Int, caption: String = "") {
        let newMessage = Message.fileMessage(
            caption: caption,
            filePath: path,
            fileSize: size,
            sender: .user
        )
        addMessage(newMessage)
        
        // Fetch agent response asynchronously
        fetchAgentResponse()
    }
    
    // MARK: - Private Methods
    
    private func addMessage(_ message: Message) {
        messages.append(message)
        messages.sort { $0.timestamp < $1.timestamp }
        persistMessages()
    }
    
    private func persistMessages() {
        do {
            try persistenceService.saveMessages(messages)
        } catch {
            errorMessage = "Failed to save messages: \(error.localizedDescription)"
            print("[ChatViewModel] Error persisting messages: \(error)")
        }
    }
    
    @MainActor
    private func fetchAgentResponse() {
        Task {
            isAgentTyping = true
            
            let response = await dataManager.fetchAgentResponse()
            
            isAgentTyping = false
            addMessage(response)
        }
    }
}
