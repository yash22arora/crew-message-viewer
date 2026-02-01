//
//  HomeView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import SwiftUI

fileprivate var chats: [Chat] = [
    .init(id: UUID().uuidString, label: "Mumbai Trip", createdAt: Date())
]

struct HomeView: View {
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // Header with branding
                headerView
                
                // Chats list
                chatsList
            }
            .navigationDestination(for: Chat.self) { chat in
                ChatView(chat: chat)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // App icon
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // App name
            Text("CrewChat")
                .font(.title)
                .fontWeight(.bold)
            
            // Tagline
            Text("Connect with your crew")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
        .padding(.top, 64)
        .background(Color(.systemBackground))
    }
    
    private var chatsList: some View {
        List {
            Section("Chats") {
                ForEach(chats) { chat in
                    NavigationLink(value: chat) {
                        Text(chat.label)
                            .padding(8)
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
