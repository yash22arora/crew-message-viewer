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
    @State private var showingImagePicker = false
    @State private var showingImageSourcePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages list
                messagesList
                
                Divider()
                
                // Input bar
                MessageInputBar(
                    messageText: $messageText,
                    onSend: sendMessage,
                    onAttachImage: { showingImageSourcePicker = true }
                )
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .navigationTitle("CrewChat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingImageSourcePicker) {
            ImageSourcePickerSheet { sourceType in
                handleImageSourceSelection(sourceType)
            }
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: imagePickerSourceType) { image in
                handleSelectedImage(image)
            }
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
        if viewModel.messages.isEmpty && !viewModel.isAgentTyping {
            emptyStateView
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        // Typing indicator
                        if viewModel.isAgentTyping {
                            typingIndicator
                                .id("typing-indicator")
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.isAgentTyping) { _, isTyping in
                    if isTyping {
                        withAnimation {
                            proxy.scrollTo("typing-indicator", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var typingIndicator: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 8, height: 8)
                        .opacity(0.6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
        }
        .padding(.vertical, 8)
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
    
    private func handleImageSourceSelection(_ sourceType: ImageSourceType) {
        showingImageSourcePicker = false
        imagePickerSourceType = sourceType.uiImagePickerSourceType
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingImagePicker = true
        }
    }
    
    private func handleSelectedImage(_ image: UIImage) {
        // Save image and send as file message
        if let result = ImageStorageService.shared.saveImage(image) {
            viewModel.sendImageMessage(path: result.path, size: result.size)
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ChatView()
}
