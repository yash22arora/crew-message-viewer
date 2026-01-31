//
//  TextMessageView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import SwiftUI

/// View for displaying text message content
struct TextMessageView: View {
    let message: Message
    
    var body: some View {
        Text(message.message)
            .font(.body)
    }
}

#Preview {
    TextMessageView(message: .textMessage("Hello, this is a text message!", sender: .user))
        .padding()
}
