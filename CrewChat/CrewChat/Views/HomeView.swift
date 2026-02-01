//
//  HomeView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
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
            .onAppear {
                viewModel.loadChats()
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
                ForEach(viewModel.chats) { chat in
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


