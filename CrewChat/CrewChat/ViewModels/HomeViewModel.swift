//
//  HomeViewModel.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import Foundation
import Combine

/// ViewModel for managing the home screen chat list
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var chats: [Chat] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let dataManager: ChatsDataManaging
    
    init(dataManager: ChatsDataManaging = ChatsDataManager()) {
        self.dataManager = dataManager
    }
    
    /// Load chats from storage
    func loadChats() {
        isLoading = true
        chats = dataManager.loadChats()
        isLoading = false
    }
    
    /// Create a new chat (for future use)
    func createChat(label: String) {
        let newChat = dataManager.createChat(label: label)
        chats.append(newChat)
    }
}
