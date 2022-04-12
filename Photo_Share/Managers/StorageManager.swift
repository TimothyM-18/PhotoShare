//
//  StorageManager.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    public func uploadProfilePicture(username: String, data: Data?, completion: @escaping (Bool) -> Void) {
        
        guard let data = data else {
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) {_, error in completion(error == nil)}
    }
    
    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {
            completion(nil)
            return
        }
        storage.child(ref).downloadURL {url, _ in
            completion(url)
            
        }
    }
    
    public func profilePicDownloadURL(for username: String, completion: @escaping (URL?) -> Void) {
        storage.child("\(username)/profile_picture.png").downloadURL {url, _ in
            completion(url)
        }
    }
    
    public func uploadPost(data: Data?, id: String, completion: @escaping (URL?) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            print("No string was fetched")
            return
        }
        guard let data = data else {
            return
        }
        
        let ref = storage.child("\(username)/posts/\(id).png")
        
        ref.putData(data, metadata: nil) {_, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }

}
