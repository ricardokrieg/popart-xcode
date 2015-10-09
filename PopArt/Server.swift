//
//  Server.swift
//  PopsArt
//
//  Created by Netronian Inc. on 17/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftHTTP
import CoreData
import Locksmith

let SERVER_ADDRESS = "popart-app.com"
let SERVER_PORT = 5200
let API_ADDRESS = "192.168.0.175"
let API_PORT = 3000

class Server {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var shouldSend = false
    
    let http_url = "http://\(SERVER_ADDRESS):\(SERVER_PORT)/"
    let signInUrl = "http://\(API_ADDRESS):\(API_PORT)/auth/sign_in"
    let signUpUrl = "http://\(API_ADDRESS):\(API_PORT)/auth"
    
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    var squareSize = 200
    var focusSquare: FocusSquareView?
    
    init() {}
    
    func doSignIn(sender: UIViewController, email: String, password: String) {
        doSignOut()
        
        do {
            let loading: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
            loading.center = sender.view.center
            loading.hidesWhenStopped = true
            loading.activityIndicatorViewStyle = .Gray
            sender.view.addSubview(loading)
            loading.startAnimating()
            
            let opt = try HTTP.POST(signInUrl, parameters: ["email": email, "password": password])
            
            opt.start { response in
                loading.stopAnimating()
                
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    self.displayAlert("Error", message: err.localizedDescription, sender: sender)
                    return
                }
                
                let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                
                let result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
                
                do {
                    if let data = json!["data"] as? NSDictionary {
                        let email = data["email"] as! String
                        let first_name = data["first_name"] as! String
                        let last_name = data["last_name"] as! String
                        let image = data["image"] as! String
                        let token: String = response.headers!["Access-Token"]!
                        
                        try self.saveAccount(email, first_name: first_name, last_name: last_name, image: image, token: token)
                        
                        self.authenticateUser("SignInViewController")
                    } else {
                        print("Error: Invalid JSON")
                    }
                } catch let error {
                    print("Error: \(error)")
                }
                
            }
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func doSignOut() {
        do {
            try Account.delete()
        } catch let error {
            print("SignOut Error: \(error)")
        }
    }
    
    func saveAccount(email: String, first_name: String, last_name: String, image: String, token: String) throws -> Account {
        let account = Account(
            email: email,
            first_name: first_name,
            last_name: last_name,
            image: image,
            token: token)
        
        try account.save()
        
        return account
    }
    
    func authenticateUser(caller: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var rootControllerIdentifier: String?
        
        if userSignedIn() {
            rootControllerIdentifier = "ViewController"
        } else {
            rootControllerIdentifier = "SignInViewController"
        }
        
        if caller != rootControllerIdentifier {
            if let window = appDelegate.window {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let rootController = storyboard.instantiateViewControllerWithIdentifier(rootControllerIdentifier!)
                    window.rootViewController = rootController
                }
            }
        }
    }
    
    func userSignedIn() -> Bool {
        if let account = Account.load() {
            print(account)
            return true
        } else {
            return false
        }
    }
    
    func ping(sender: UIViewController) -> Bool {
        var s:Bool = true
        
        do {
            let opt = try HTTP.GET(http_url, parameters: nil)
            
            opt.start { response in
                if let err = response.error {
                    s = false
                    print("error: \(err.localizedDescription)")
                    self.displayAlert("Error", message: err.localizedDescription, sender: sender)
                    return
                }
            }
        } catch let error {
            s = false
            print("got an error creating the request: \(error)")
        }
        
        return s
    }
    
    func displayAlert(title: String, message: String, sender: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                if sender.isKindOfClass(SendingPictureViewController) {
                    sender.performSegueWithIdentifier("fromSendingToMain", sender: sender)
                }
            }
        ))
        
        sender.presentViewController(alertController, animated: true, completion: nil)
    }
}

let server = Server()