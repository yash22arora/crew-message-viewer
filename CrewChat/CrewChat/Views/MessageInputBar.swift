//
//  MessageInputBar.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import SwiftUI

/// Input bar for composing and sending messages
struct MessageInputBar: View {
    @Binding var messageText: String
    var hasImageAttached: Bool
    var onSend: () -> Void
    var onAttachImage: () -> Void
    
    private var canSend: Bool {
        hasImageAttached || !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Attachment button
            Button(action: onAttachImage) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }
            
            // Text field
            TextField("Type a message...", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Send button
            Button(action: {
                onSend()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canSend ? .blue : .gray)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack {
        Spacer()
        MessageInputBar(
            messageText: .constant(""),
            hasImageAttached: false,
            onSend: {},
            onAttachImage: {}
        )
    }
}
