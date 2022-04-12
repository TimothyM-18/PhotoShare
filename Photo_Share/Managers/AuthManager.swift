//
//  AuthManager.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import FirebaseAuth
import Foundation

final class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    let auth = Auth.auth()
    
    enum AuthError: Error {
        case newUserCreation
        case signIfailed
    }
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        
            DatabaseManager.shared.findUser(with: email) { [weak self] user in
                guard let user = user else {
                    completion(.failure(AuthError.newUserCreation))
                    return
                }
                
                self?.auth.signIn(withEmail: email, password: password) { result, error in
                    guard result != nil, error == nil else {
                        completion(.failure(AuthError.signIfailed))
                        return
                    }
                    
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    
                    completion(.success(user))
                }
            }
        
    }
    
    public func signUp(username: String, email: String, password: String, profilePicture: Data?, completion: @escaping (Result<User, Error>) -> Void) {
        
        let newUser = User(username: username, email: email)
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(.failure(AuthError.newUserCreation))
                return
            }
            
            DatabaseManager.shared.createUser(newUser: newUser) {success in
                if success {
                    StorageManager.shared.uploadProfilePicture(username: username, data: profilePicture) { uploadSuccess in
                        if uploadSuccess {
                            completion(.success(newUser))
                        } else {
                            completion(.failure(AuthError.newUserCreation))
                        }
                    }
                }
                else {
                    completion(.failure(AuthError.newUserCreation))
                }
            }
            
        }
    }
    
    
    public func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            print(error)
            completion(false)
            return
        }
    }
}
