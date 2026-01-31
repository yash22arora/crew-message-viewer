//
//  ImageSourcePickerSheet.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 01/02/26.
//

import SwiftUI

// MARK: - Image Source Type Enum

enum ImageSourceType {
    case camera
    case photoLibrary
    
    var uiImagePickerSourceType: UIImagePickerController.SourceType {
        switch self {
        case .camera:
            return .camera
        case .photoLibrary:
            return .photoLibrary
        }
    }
}

// MARK: - Delegate Protocol

protocol ImageSourcePickerDelegate: AnyObject {
    func imageSourcePicker(didSelect sourceType: ImageSourceType)
}

// MARK: - Image Source Picker Sheet

/// Bottom sheet for selecting image source (camera or photo library)
struct ImageSourcePickerSheet: View {
    let onSelect: (ImageSourceType) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Handle bar indicator
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.vertical, 8)
            
            Text("Choose Image Source")
                .font(.headline)
                .padding(.top, 16)
                .padding(.bottom, 24)
            
            HStack(spacing: 32) {
                // Photo Library option
                SourceOptionButton(
                    icon: "photo.on.rectangle",
                    title: "Photo Library",
                    action: { onSelect(.photoLibrary) }
                )
                
                // Camera option
                if isCameraAvailable {
                    SourceOptionButton(
                        icon: "camera",
                        title: "Camera",
                        action: { onSelect(.camera) }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            Spacer()
        }
    }
}

/// Individual source option button with icon and label
private struct SourceOptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                    .frame(width: 70, height: 70)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    ImageSourcePickerSheet(onSelect: { _ in })
}

