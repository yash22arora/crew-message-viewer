//
//  Message.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import Foundation

enum MessageType: String, Codable {
    case text
    case file
}

enum Sender: String, Codable {
    case user
    case agent
}

struct Thumbnail: Codable, Equatable {
    let path: String
}

// MARK: - FileInfo
struct FileInfo: Codable, Equatable {
    let path: String
    let fileSize: Int
    let thumbnail: Thumbnail?
    
    init(path: String, fileSize: Int, thumbnail: Thumbnail? = nil) {
        self.path = path
        self.fileSize = fileSize
        self.thumbnail = thumbnail
    }
}

// MARK: - Message
struct Message: Codable, Identifiable, Equatable {
    let id: String
    let message: String
    let type: MessageType
    let file: FileInfo?
    let sender: Sender
    let timestamp: TimeInterval // Milliseconds since epoch
    
    // MARK: - Computed Properties
    
    /// Returns the timestamp as a Date object
    var date: Date {
        Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    // MARK: - Initializers
    
    /// Full initializer
    init(id: String = UUID().uuidString,
         message: String,
         type: MessageType,
         file: FileInfo? = nil,
         sender: Sender,
         timestamp: TimeInterval) {
        self.id = id
        self.message = message
        self.type = type
        self.file = file
        self.sender = sender
        self.timestamp = timestamp
    }
    
    /// Convenience initializer for text messages
    static func textMessage(_ text: String, sender: Sender, timestamp: TimeInterval? = nil) -> Message {
        Message(
            message: text,
            type: .text,
            sender: sender,
            timestamp: timestamp ?? Date().timeIntervalSince1970 * 1000
        )
    }
    
    /// Convenience initializer for file messages
    static func fileMessage(caption: String = "",
                            filePath: String,
                            fileSize: Int,
                            thumbnailPath: String? = nil,
                            sender: Sender,
                            timestamp: TimeInterval? = nil) -> Message {
        let thumbnail = thumbnailPath.map { Thumbnail(path: $0) }
        let fileInfo = FileInfo(path: filePath, fileSize: fileSize, thumbnail: thumbnail)
        
        return Message(
            message: caption,
            type: .file,
            file: fileInfo,
            sender: sender,
            timestamp: timestamp ?? Date().timeIntervalSince1970 * 1000
        )
    }
}
