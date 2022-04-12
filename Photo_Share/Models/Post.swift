//
//  Post.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import Foundation

struct Post: Codable {
    let identfier: String
    let caption: String
    let postedDate: String
    let postUrlString: String
    var likers: [String]
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return nil}
        return "\(username)/posts/\(identfier).png"
    }
}

