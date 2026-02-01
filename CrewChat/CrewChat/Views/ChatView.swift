//
//  ChatView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import SwiftUI

/// Main chat view displaying messages and input bar
struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @State private var showingImageSourcePicker = false
    @State private var selectedImageSource: ImageSourceType? = nil
    @State private var pendingImage: UIImage? = nil
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    init(chat: Chat) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(chat: chat))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            messagesList
            
            Divider()
            
            // Image preview (if pending)
            if let image = pendingImage {
                ImagePreviewBarView(image: image) {
                    discardPendingImage()
                }
            }
            
            // Input bar
            MessageInputBar(
                messageText: $messageText,
                hasImageAttached: pendingImage != nil,
                onSend: sendMessage,
                onAttachImage: { showingImageSourcePicker = true }
            )
        }
        .onTapGesture {
            dismissKeyboard()
        }
        .navigationTitle(viewModel.chat.label)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImageSourcePicker) {
            ImageSourcePickerSheet { sourceType in
                handleImageSourceSelection(sourceType)
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedImageSource) { sourceType in
            ImagePicker(sourceType: sourceType.uiImagePickerSourceType) { image in
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
                .onChange(of: verticalSizeClass) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: pendingImage) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
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
                    TypingDot(delay: Double(index) * 0.3)
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
        
        if pendingImage != nil {
            sendImageWithCaption()
        }
        else {
            let text = messageText
            messageText = ""
            viewModel.sendMessage(text)
        }
    }
    
    private func handleImageSourceSelection(_ sourceType: ImageSourceType) {
        showingImageSourcePicker = false
        
        // Use asyncAfter to ensure the source picker sheet is fully dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            selectedImageSource = sourceType
        }
    }
    
    private func handleSelectedImage(_ image: UIImage) {
        // Store image for preview, don't send yet
        pendingImage = image
    }
    
    private func sendImageWithCaption() {
        guard let image = pendingImage else { return }
        
        // Save image and send as file message with caption
        if let result = ImageStorageService.shared.saveImage(image) {
            let caption = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            viewModel.sendImageMessage(path: result.path, size: result.size, caption: caption)
        }
        
        // Clear pending image and text
        pendingImage = nil
        messageText = ""
    }
    
    private func discardPendingImage() {
        pendingImage = nil
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

// MARK: - Typing Dot Animation

private struct TypingDot: View {
    let delay: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(Color.secondary)
            .frame(width: 8, height: 8)
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .opacity(isAnimating ? 1.0 : 0.4)
            .animation(
                Animation
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    NavigationStack {
        ChatView(chat: .init(id: "test-chat", label: "Test Chat", createdAt: Date()))
    }
}
