//
//  DatabaseManager.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func posts(for username: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        let ref = database.collection("users").document(username).collection("posts")
        ref.getDocuments {snapshot, error in
            guard let posts = snapshot?.documents.compactMap({
                Post(with: $0.data())
            }), error == nil else {
                return
            }
            completion(.success(posts))
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            
            let user = users.first(where: { $0.email == email})
            completion(user)
        }
    }
    

    func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let reference = database.document("users/\(username)/posts/\(newPost.identfier)")

        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    
    public func findUsers(with usernamePrefix: String, completion: @escaping ([User]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })
            completion(subset)

        }
    }
    
    public func explorePosts(completion: @escaping ([(post: Post, user: User)]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var aggregatePosts = [(post: Post, user: User)]()
            
            users.forEach { user in
                group.enter()
                let username = user.username
                let postRef = self.database.collection("users").document(username).collection("posts")
               
                postRef.getDocuments { snapshot, error in
                    
                    defer {
                        group.leave()
                    }
                    
                    guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                        return
                    }
                    
                    aggregatePosts.append(contentsOf: posts.compactMap({
                        (post: $0, user: user)
                    }))
                }
            }
            group.notify(queue: .main){
               completion(aggregatePosts)
            }
        }
    }
    
    public func isFriend(targetUsername: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let userRef = database.collection("users").document(targetUsername).collection("friends").document(currentUsername)
        
        userRef.getDocument { snapshot, error in
            guard snapshot != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    public func friends(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users").document(username).collection("friends")
        ref.getDocuments { snapshot, error in
            guard let usernames  = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    public func getPost(with identifier: String, from username: String, completion: @escaping (Post?) -> Void) {
        let ref = database.collection("users").document(username).collection("posts").document(identifier)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            completion(Post(with: data))
        }
        
    }
    
    
    
   
    public func getUserInfo(username: String, completion: @escaping (UserInfo?) -> Void) {
        let ref = database.collection("users").document(username).collection("information").document("details")
        
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(), let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    public func setUserInfo(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        
        guard let username = UserDefaults.standard.string(forKey: "username"),
        let data = userInfo.asDictionary() else {
            return
        }
        
        let ref = database.collection("users").document(username).collection("information").document("details")
        
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func getComments(postID: String, owner: String, completion: @escaping ([Comment]) -> Void) {
        let ref = database.collection("users").document(owner).collection("posts").document(postID).collection("comments")
        
        ref.getDocuments { snapshot, error in
            guard let comments = snapshot?.documents.compactMap({
                Comment(with: $0.data())
            }), error == nil else {
                completion([])
                return
            }
            completion(comments)
        }
    }
    
    public func createComments(comment: Comment, postID: String, owner: String, completion: @escaping (Bool) -> Void) {
   
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...1000))"
        let ref = database.collection("users").document(owner).collection("posts").document(postID).collection("comments").document(newIdentifier)
        
        guard let data = comment.asDictionary() else {
            return
        }
        ref.setData(data) { error in
           completion(error == nil)
        }
    }
    
    enum LikeState {
        case like, unlike
    }
    
    
    public func updateLikeState(state: LikeState, postID: String, owner: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        
        let ref = database.collection("users").document(owner).collection("posts").document(postID)
        
        getPost(with: postID, from: owner) { post in
            guard var post = post else {
                completion(false)
                return
            }
            
            switch state {
            case .like:
                if !post.likers.contains(currentUsername){
                    post.likers.append(currentUsername)
                }
            case .unlike:
                post.likers.removeAll(where: {$0 == currentUsername})
            }
    
            guard let data = post.asDictionary() else {
                completion(false)
                return
            }
            
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}
