//
//  Session.swift
//  PopsArt
//
//  Created by Netronian Inc. on 08/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import Foundation
import Locksmith

class Account {
    var email: String
    var first_name: String
    var last_name: String
    var image: String
    var token: String
    
    class func load() -> Account? {
        if let result = Locksmith.loadDataForUserAccount("PopArtAccount") {
            return Account(
                email: result["email"] as! String,
                first_name: result["first_name"] as! String,
                last_name: result["last_name"] as! String,
                image: result["image"] as! String,
                token: result["token"] as! String)
        } else {
            return nil
        }
    }
    
    class func delete() throws {
        try Locksmith.deleteDataForUserAccount("PopArtAccount")
    }
    
    init(email: String, first_name: String, last_name: String, image: String, token: String) {
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.image = image
        self.token = token
    }
    
    func save() throws {
        let data = [
            "email": email,
            "first_name": first_name,
            "last_name": last_name,
            "image": image,
            "token": token
        ]
        
        try Locksmith.updateData(data, forUserAccount: "PopArtAccount")
    }
}