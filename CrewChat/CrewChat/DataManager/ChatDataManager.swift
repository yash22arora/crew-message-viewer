//
//  ChatDataManager.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import Foundation

protocol ChatDataManaging {
    func fetchAgentResponse() async -> Message
}

fileprivate let dummyResponses: [String] = [
    "Thanks for reaching out! How can I help you today?",
    "I understand. Let me look into that for you.",
    "That's a great question! Here's what I found...",
    "I appreciate your patience. Is there anything else you'd like to know?",
    "Got it! I'll make a note of that.",
    "Happy to help! Feel free to ask me anything.",
    "Let me check that for you. One moment please.",
    "That's interesting! Tell me more about it.",
    "I see what you mean. Here's what I suggest...",
    "Thanks for sharing! I'll keep that in mind.",
    "Absolutely! I can definitely help with that.",
    "Let me clarify that for you right away.",
    "Great choice! I think that will work perfectly.",
    "I'm here to assist you. What else do you need?",
    "That makes sense. Let me provide some options...",
    "Sure thing! Here's the information you requested.",
    "I'd be happy to explain that in more detail.",
    "Perfect! Is there anything else I can do for you?",
    "Thanks for your message! Let me get back to you on that.",
    "I appreciate your feedback! It helps us improve."
]

/// Service for fetching simulated agent responses
final class ChatDataManager: ChatDataManaging {
    
    /// Fetch a simulated agent response with artificial delay
    /// - Returns: A randomly selected agent response message
    func fetchAgentResponse() async -> Message {
        // Simulate network latency (0.5 to 2.0 seconds)
        let delay = Double.random(in: 1.0...2.5)
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        let responseText = dummyResponses.randomElement() ?? "An error occured. Please try again later."

        return Message.textMessage(responseText, sender: .agent)
    }
}
