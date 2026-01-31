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
    
    @State private var showFullScreenImage = false
    
    /// Full resolution image path for full screen view
    private var fullImagePath: String? {
        message.file?.path
    }
    
    private var imagePath: String? {
        // Prefer thumbnail if available, otherwise use main file path
        message.file?.thumbnail?.path ?? message.file?.path
    }
    
    private var fileSizeText: String {
        guard let size = message.file?.fileSize else { return "" }
        return ImageStorageService.shared.getImageSizeInText(size: size)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            imageView
                .onTapGesture {
                    if fullImagePath != nil {
                        showFullScreenImage = true
                    }
                }
            
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
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let path = fullImagePath {
                FullScreenImageView(imagePath: path)
            }
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let path = imagePath {
            if ImageStorageService.shared.isRemoteURL(path), let url = URL(string: path) {
                // Load from remote URL using AsyncImage
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else if let image = ImageStorageService.shared.loadLocalImage(from: path) {
                // Load from local file path
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                imagePlaceholder
            }
        } else {
            imagePlaceholder
        }
    }
    
    private var imagePlaceholder: some View {
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

#Preview {
    ImageMessageView(message: .fileMessage(
        caption: "Check out this image!",
        filePath: "/path/to/image.jpg",
        fileSize: 1024 * 512,
        sender: .user
    ))
    .padding()
}
