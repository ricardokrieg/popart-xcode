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
    var uid: String
    var first_name: String
    var last_name: String
    var image: String
    var token: String
    var client: String
    
    class func load() -> Account? {
        if let result = Locksmith.loadDataForUserAccount("PopArtAccount") {
            return Account(
                uid: result["uid"] as! String,
                first_name: result["first_name"] as! String,
                last_name: result["last_name"] as! String,
                image: result["image"] as! String,
                token: result["token"] as! String,
                client: result["client"] as! String)
        } else {
            return nil
        }
    }
    
    class func delete() throws {
        try Locksmith.deleteDataForUserAccount("PopArtAccount")
    }
    
    init(uid: String, first_name: String, last_name: String, image: String, token: String, client: String) {
        self.uid = uid
        self.first_name = first_name
        self.last_name = last_name
        self.image = image
        self.token = token
        self.client = client
    }
    
    func save() throws {
        let data = [
            "uid": uid,
            "first_name": first_name,
            "last_name": last_name,
            "image": image,
            "token": token,
            "client": client
        ]
        
        print("Saving Account")
        print(data)
        
        do {
            try Account.delete()
        } catch _ {}
        
        try Locksmith.updateData(data, forUserAccount: "PopArtAccount")
    }
}