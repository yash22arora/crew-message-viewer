//
//  ChatView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import SwiftUI

/// Main chat view displaying messages and input bar
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                messagesList
                
                Divider()
                
                // TODO: Input bar
                
            }
            .navigationTitle("CrewChat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Messages List
    
    @ViewBuilder
    private var messagesList: some View {
        if viewModel.messages.isEmpty {
            emptyStateView
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Messages Yet")
                .font(.title2)
                .fontWeight(.medium)
            Text("Start a conversation by sending a message")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let text = messageText
        messageText = ""
        viewModel.sendMessage(text)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

#Preview {
    ChatView()
}
