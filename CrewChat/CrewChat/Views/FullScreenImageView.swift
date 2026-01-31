//
//  FullScreenImageView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import SwiftUI

/// Full screen image viewer with pinch-to-zoom and pan gestures
struct FullScreenImageView: View {
    let imagePath: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                imageContent
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, minScale), maxScale)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                if scale < minScale {
                                    withAnimation(.spring()) {
                                        scale = minScale
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if scale > 1 {
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.5
                            }
                        }
                    }
            }
            .overlay(alignment: .topTrailing) {
                closeButton
            }
        }
    }
    
    @ViewBuilder
    private var imageContent: some View {
        if ImageStorageService.shared.isRemoteURL(imagePath), let url = URL(string: imagePath) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    errorView
                @unknown default:
                    errorView
                }
            }
        } else if let uiImage = ImageStorageService.shared.loadLocalImage(from: imagePath) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            errorView
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.8))
                .padding()
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Unable to load image")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    FullScreenImageView(imagePath: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800")
}
