//
//  StorageManager.swift
//  SwiftMessenger
//
//  Created by max on 24.12.2021.
//

import Foundation
import FirebaseStorage
import UIKit
import MapKit

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private var storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print ("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print ("Failed to get downlod URL")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print ("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL,Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))

        })
    }
    /// Upload image that will be sent in conversation message
    public func uploadMessagePhoto(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print ("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print ("Failed to get downlod URL")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print ("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
    // Upload video
    public func uploadMessageVideo(with fileUrl: URL,
                                   fileName: String,
                                   completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                print ("Failed to upload data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print ("Failed to get downlod URL")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print ("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
        
    }
}
