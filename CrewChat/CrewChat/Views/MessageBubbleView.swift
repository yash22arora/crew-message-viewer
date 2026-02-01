//
//  MessageBubbleView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import SwiftUI

/// A bubble view for displaying a single chat message
struct MessageBubbleView: View {
    let message: Message
    
    private var isUserMessage: Bool {
        message.sender == .user
    }
    
    private var bubbleColor: Color {
        isUserMessage ? .blue : Color(.systemGray5)
    }
    
    private var textColor: Color {
        isUserMessage ? .white : .primary
    }
    
    private var alignment: HorizontalAlignment {
        isUserMessage ? .trailing : .leading
    }
    
    var body: some View {
        HStack {
            if isUserMessage {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: alignment, spacing: 4) {
                // Message content
                messageContent
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(bubbleColor)
                    .foregroundColor(textColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .contextMenu {
                        if message.type == .text {
                            copyButton
                        }
                        
                        // Can add more options here like:
                        // Button { } label: { Label("Reply", systemImage: "arrowshape.turn.up.left") }
                        // Button(role: .destructive) { } label: { Label("Delete", systemImage: "trash") }
                    }
                
                // Timestamp
                Text(DateFormatters.formatSmartTimestamp(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isUserMessage {
                Spacer(minLength: 60)
            }
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var messageContent: some View {
        switch message.type {
        case .text:
            TextMessageView(message: message)
        case .file:
            ImageMessageView(message: message)
        }
    }
    
    private var copyButton: some View {
        Button {
            copyMessageText()
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
    }
    
    private func copyMessageText() {
        guard message.type == .text else { return }
        let text = message.message
        
        // Copy to clipboard
        UIPasteboard.general.string = text
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview("User Message") {
    MessageBubbleView(message: .textMessage("Hello! This is a user message.", sender: .user))
        .padding()
}

#Preview("Agent Message") {
    MessageBubbleView(message: .textMessage("Hi! This is an agent response with some longer text to show wrapping.", sender: .agent))
        .padding()
}
