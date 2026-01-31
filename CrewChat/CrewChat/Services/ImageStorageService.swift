//
//  ImageStorageService.swift
//  CrewChat
//
//  Created by Yashvardhan Arora on 31/01/26.
//

import UIKit

/// Service for saving and managing images locally
final class ImageStorageService {
    
    static let shared = ImageStorageService()
    
    private let fileManager = FileManager.default
    private let persistenceService = PersistenceService.shared
    
    private init() {}
    
    /// Save an image to local storage
    /// - Parameter image: The UIImage to save
    /// - Returns: Tuple containing the relative file path and file size, or nil if save fails
    func saveImage(_ image: UIImage) -> (path: String, size: Int)? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("[ImageStorageService] Failed to convert image to JPEG data")
            return nil
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = persistenceService.imagesDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            let relativePath = "\(Constants.Files.imagesDirectoryName)/\(fileName)"
            let fileSize = imageData.count
            
            print("[ImageStorageService] Saved image: \(relativePath), size: \(fileSize) bytes")
            return (relativePath, fileSize)
        } catch {
            print("[ImageStorageService] Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Delete an image from local storage
    /// - Parameter path: The relative path to the image
    /// - Returns: True if deletion was successful
    @discardableResult
    func deleteImage(at path: String) -> Bool {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(path)
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("[ImageStorageService] Deleted image: \(path)")
            return true
        } catch {
            print("[ImageStorageService] Error deleting image: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Get the full URL for an image path
    /// - Parameter path: The relative path to the image
    /// - Returns: The full file URL
    func fullURL(for path: String) -> URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL.appendingPathComponent(path)
    }
    
    // MARK: - Image Loading Utilities
    
    /// Check if a path is a remote URL
    /// - Parameter path: The path to check
    /// - Returns: True if the path is an HTTP/HTTPS URL
    func isRemoteURL(_ path: String) -> Bool {
        path.hasPrefix("http://") || path.hasPrefix("https://")
    }
    
    /// Load an image from a local path
    /// - Parameter path: The file path (absolute or relative to Documents)
    /// - Returns: The loaded UIImage, or nil if not found
    func loadLocalImage(from path: String) -> UIImage? {
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
    
    func getImageSizeInText(size: Int) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}
