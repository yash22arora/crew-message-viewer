//
//  ImageMessageView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import SwiftUI

/// View for displaying image/file message content
struct ImageMessageView: View {
    let message: Message
    
    private var imagePath: String? {
        // Prefer thumbnail if available, otherwise use main file path
        message.file?.thumbnail?.path ?? message.file?.path
    }
    
    private var fileSizeText: String {
        guard let size = message.file?.fileSize else { return "" }
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            imageView
            
            // Caption (if any)
            if !message.message.isEmpty {
                Text(message.message)
                    .font(.body)
            }
            
            // File size
            if let _ = message.file?.fileSize {
                Text(fileSizeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let path = imagePath, let image = loadImage(from: path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200, maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            // Fallback for failed image load
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("Image unavailable")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 150, height: 100)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func loadImage(from path: String) -> UIImage? {
        // Handle both absolute paths and relative paths in Documents directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Try absolute path first
        if fileManager.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        }
        
        // Try relative path from Documents
        let absoluteURL = documentsURL.appendingPathComponent(path)
        if fileManager.fileExists(atPath: absoluteURL.path) {
            return UIImage(contentsOfFile: absoluteURL.path)
        }
        
        return nil
    }
}

#Preview {
    ImageMessageView(message: .fileMessage(
        caption: "Check out this image!",
        filePath: "/path/to/image.jpg",
        fileSize: 1024 * 512,
        sender: .user
    ))
    .padding()
}
