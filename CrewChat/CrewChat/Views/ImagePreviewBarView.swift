//
//  ImagePreviewBarView.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 02/02/26.
//
import SwiftUI

struct ImagePreviewBarView: View {
    let image: UIImage
    var onDiscard: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Image thumbnail
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Image Selected")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Add a caption or send now")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Dismiss button
            Button {
                onDiscard()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
}
