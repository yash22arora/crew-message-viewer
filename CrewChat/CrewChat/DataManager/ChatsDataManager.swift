//
//  ChatsDataManager.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import Foundation

// MARK: - Protocol

protocol ChatsDataManaging {
    func loadChats() -> [Chat]
    func createChat(label: String) -> Chat
}

// MARK: - Implementation

final class ChatsDataManager: ChatsDataManaging {
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = .shared) {
        self.persistenceService = persistenceService
    }
    
    /// Load chats from storage, creating default if none exist
    func loadChats() -> [Chat] {
        return persistenceService.loadOrCreateDefaultChats()
    }
    
    /// Create a new chat with the given label
    func createChat(label: String) -> Chat {
        return persistenceService.createChat(label: label)
    }
}
