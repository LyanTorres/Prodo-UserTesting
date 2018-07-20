//
//  User.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/15/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import Foundation

struct User: Codable {
    let email: String
    let _id: String
    var token: String!
    let stores: [String]
    
    init(email: String, _id: String, stores: [String]) {
        self.email = email
        self._id = _id
        self.stores = stores
    }
    
    static func saveCurrentUser(user: User) {
        print("saving")
        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: "CurrentUser")
    }
    
    static func currentUser() -> User? {
        if let data = UserDefaults.standard.value(forKey:"CurrentUser") as? Data {
            return try? PropertyListDecoder().decode(User.self, from: data)
        }
        return nil
    }
    
    static func eraseCurrentUser(){
        UserDefaults.standard.set(nil, forKey: "CurrentUser")
    }
}
