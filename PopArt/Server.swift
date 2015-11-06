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
let SERVER_PORT = 5300
let API_ADDRESS = "popart-app.com"
//let API_ADDRESS = "192.168.0.175"
let API_PORT = 80
//let API_PORT = 3000

class Server {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var shouldSend = false
    var shouldCheckToken = true
    
    let http_url = "http://\(SERVER_ADDRESS):\(SERVER_PORT)/"
    let signInUrl = "http://popart-app.com/auth/sign_in"
    let signUpUrl = "http://popart-app.com/auth"
    let resetPasswordUrl = "http://popart-app.com/auth/password"
    let resetPasswordRedirectUrl = "http://popart-app.com/auth/password"
    let updateProfileUrl = "http://popart-app.com/auth/"
    let validateTokenUrl = "http://popart-app.com/auth/validate_token"
    let createTicketUrl = "http://popart-app.com/tickets.json"
    
    let termsOfServiceUrl = "http://\(API_ADDRESS)/pages/terms-of-service"
    let privacyPolicyUrl = "http://\(API_ADDRESS)/pages/privacy-policy"
    let aboutUsUrl = "http://\(API_ADDRESS)/pages/about-us"
    
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    var squareSize = 200
    var focusSquare: FocusSquareView?
    
    init() {}
    
    func doSignIn(sender: UIViewController, email: String, password: String) {
        let loading = self.displayLoading(sender.view)
        
        doSignOut()
        
        do {
            let opt = try HTTP.POST(signInUrl, parameters: ["email": email, "password": password])
            
            self.doSignRequest(opt, sender: sender, loading: loading)
        } catch let error {
            loading.stopAnimating()
            print("Error: \(error)")
        }
    }
    
    func doSignUp(sender: UIViewController, email: String, password: String, first_name: String, last_name: String) {
        let loading = self.displayLoading(sender.view)
        
        doSignOut()
        
        do {
            let opt = try HTTP.POST(signUpUrl, parameters: ["email": email, "password": password, "first_name": first_name, "last_name": last_name])
            
            self.doSignRequest(opt, sender: sender, loading: loading)
        } catch let error {
            loading.stopAnimating()
            print("Error: \(error)")
        }
    }
    
    func doResetPassword(sender: UIViewController, email: String) {
        let loading = self.displayLoading(sender.view)
        
        do {
            let opt = try HTTP.POST(resetPasswordUrl, parameters: ["email": email, "redirect_url": resetPasswordRedirectUrl])
            
            opt.start { response in
                dispatch_async(dispatch_get_main_queue(), {
                    loading.stopAnimating()
                })
                
                let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                let result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
                
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                    
                    var alertMessage = err.localizedDescription
                    if let errors = json!["errors"] as? NSDictionary {
                        if let fullMessages = errors["full_messages"] as? NSArray {
                            alertMessage = fullMessages.componentsJoinedByString("\n")
                        }
                    } else if let singleError = json!["errors"] as? NSArray {
                        alertMessage = singleError.componentsJoinedByString("\n")
                    }
                    
                    self.displayAlert("Error", message: alertMessage, sender: sender)
                    
                    return
                }
                
                if let message = json!["message"] as? String {
                    self.displayAlert("Info", message: message, sender: sender)
                } else {
                    print("Error: Invalid JSON")
                }
            }
        } catch let error {
            loading.stopAnimating()
            print("Error: \(error)")
        }
    }
    
    func doUpdateProfile(sender: UIViewController, first_name: String, last_name: String, email: String, password: String, image: UIImage?) {
        let loading = self.displayLoading(sender.view)
        
        do {
            if let account = Account.load() {
                let uid = account.uid
                let token = account.token
                let client = account.client
                
                var parameters: Dictionary<String, AnyObject> = ["uid": uid, "access-token": token, "client": client, "first_name": first_name, "last_name": last_name, "email": email]
                
                if password != "" {
                    parameters["password"] = password
                }
                
                if image != nil {
                    parameters["image"] = Upload(data: UIImageJPEGRepresentation(image!, 0.5)!, fileName: "upload.jpg", mimeType: "image/jpeg")
                }
            
                let opt = try HTTP.PUT(updateProfileUrl, parameters: parameters)
            
                opt.start { response in
                    dispatch_async(dispatch_get_main_queue(), {
                        loading.stopAnimating()
                    })
                
                    let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                    let result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
                
                    print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                    if let err = response.error {
                        print("error: \(err.localizedDescription)")
                        print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                    
                        var alertMessage = err.localizedDescription
                        if let errors = json!["errors"] as? NSDictionary {
                            if let fullMessages = errors["full_messages"] as? NSArray {
                                alertMessage = fullMessages.componentsJoinedByString("\n")
                            }
                        } else if let singleError = json!["errors"] as? NSArray {
                            alertMessage = singleError.componentsJoinedByString("\n")
                        }
                    
                        self.displayAlert("Error", message: alertMessage, sender: sender)
                    
                        return
                    }
                
                    do {
                        if let data = json!["data"] as? NSDictionary {
                            let email = data["email"] as! String
                            let first_name = data["first_name"] as! String
                            let last_name = data["last_name"] as! String
                            var image_url = ""
                            if let image = data["image"] as? NSDictionary {
                                image_url = image["url"] as! String
                            }
                            let token: String = response.headers!["Access-Token"]!
                            let client: String = response.headers!["Client"]!
                        
                            try self.saveAccount(email, first_name: first_name, last_name: last_name, image: image_url, token: token, client: client)
                        
                            self.displayAlert("Info", message: "Profile updated", sender: sender)
                        } else {
                            print("Error: Invalid JSON")
                        }
                    } catch let error {
                        print("Error: \(error)")
                    }
                }
            } else {
                print("Error: Error loading Account")
                self.displayAlert("Error", message: "Error loading Account", sender: sender)
            }
        } catch let error {
            loading.stopAnimating()
            print("Error: \(error)")
        }
    }
    
    func doCreateTicket(sender: UIViewController, subject: String, content: String) {
        let loading = self.displayLoading(sender.view)
        
        do {
            if let account = Account.load() {
                let uid = account.uid
                let token = account.token
                let client = account.client
        
                let opt = try HTTP.POST(createTicketUrl, parameters: ["uid": uid, "access-token": token, "client": client, "ticket[subject]": subject, "ticket[content]": content])
            
                opt.start { response in
                    dispatch_async(dispatch_get_main_queue(), {
                        loading.stopAnimating()
                    })
                
                    let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                    let result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                    let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
                
                    if let err = response.error {
                        print("error: \(err.localizedDescription)")
                        print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                    
                        var alertMessage = err.localizedDescription
                        if let errors = json!["errors"] as? NSDictionary {
                            if let fullMessages = errors["full_messages"] as? NSArray {
                                alertMessage = fullMessages.componentsJoinedByString("\n")
                            }
                        } else if let singleError = json!["errors"] as? NSArray {
                            alertMessage = singleError.componentsJoinedByString("\n")
                        }
                    
                        self.displayAlert("Error", message: alertMessage, sender: sender)
                    
                        return
                    }
                
                    if let message = json!["message"] as? String {
                        self.displayAlert("Info", message: message, sender: sender)
                    } else {
                        print("Error: Invalid JSON")
                        print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                    }
                }
            } else {
                print("Error: Error loading Account")
                self.displayAlert("Error", message: "Error loading Account", sender: sender)
            }
        } catch let error {
            loading.stopAnimating()
            print("Error: \(error)")
        }
    }
    
    func doSignRequest(opt: HTTP, sender: UIViewController, loading: UIActivityIndicatorView) {
        opt.start { response in
            dispatch_async(dispatch_get_main_queue(), {
                loading.stopAnimating()
            })
            
            let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
            let result = str!.dataUsingEncoding(NSUTF8StringEncoding)
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                
                var alertMessage = err.localizedDescription
                if let errors = json!["errors"] as? NSDictionary {
                    if let fullMessages = errors["full_messages"] as? NSArray {
                        alertMessage = fullMessages.componentsJoinedByString("\n")
                    }
                } else if let singleError = json!["errors"] as? NSArray {
                    alertMessage = singleError.componentsJoinedByString("\n")
                }
                
                self.displayAlert("Error", message: alertMessage, sender: sender)
                
                return
            }
            
            do {
                print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                if let data = json!["data"] as? NSDictionary {
                    let email = data["email"] as! String
                    let first_name = data["first_name"] as! String
                    let last_name = data["last_name"] as! String
                    var image_url = ""
                    if let image = data["image"] as? NSDictionary {
                        image_url = image["url"] as! String
                    }
                    let token: String = response.headers!["Access-Token"]!
                    let client: String = response.headers!["Client"]!
                    
                    print("doSignRequest")
                    try self.saveAccount(email, first_name: first_name, last_name: last_name, image: image_url, token: token, client: client)
                    
                    server.shouldCheckToken = false
                    self.authenticateUser("SignInViewController", checkToken: false)
                } else {
                    print("Error: Invalid JSON")
                }
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    func doSignOut() {
        do {
            try Account.delete()
        } catch let error {
            print("SignOut Error: \(error)")
        }
    }
    
    func saveAccount(uid: String, first_name: String, last_name: String, image: String, token: String, client: String) throws -> Account {
        let account = Account(
            uid: uid,
            first_name: first_name,
            last_name: last_name,
            image: "http://\(API_ADDRESS)\(image)",
            token: token,
            client: client)
        
        try account.save()
        
        return account
    }
    
    func authenticateUser(caller: String, checkToken: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var rootControllerIdentifier = "SignInViewController"

        if checkToken {
            if let account = Account.load() {
                if tokenIsValid(account) {
                    rootControllerIdentifier = "ViewController"
                }  else {
                    doSignOut()
                }
            }
        } else {
            rootControllerIdentifier = "ViewController"
        }
        
        if caller != rootControllerIdentifier {
            if let window = appDelegate.window {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let rootController = storyboard.instantiateViewControllerWithIdentifier(rootControllerIdentifier)
                    window.rootViewController = rootController
                }
            }
        }
    }
    
    func tokenIsValid(account: Account) -> Bool {
        var success = true
        
        do {
            let opt = try HTTP.GET(validateTokenUrl, parameters: ["uid": account.uid, "access-token": account.token, "client": account.client])
                    
            opt.start { response in
                let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                let result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
                        
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    print("Body: \(NSString(data: response.data, encoding: NSUTF8StringEncoding))")
                            
                    success = false
                    return
                }
                        
                do {
                    if let data = json!["data"] as? NSDictionary {
                        let email = data["email"] as! String
                        let first_name = data["first_name"] as! String
                        let last_name = data["last_name"] as! String
                        var image_url = ""
                        if let image = data["image"] as? NSDictionary {
                            image_url = image["url"] as! String
                        }
                        let token: String = account.token
                        let client: String = account.client
                        
                        print("tokenIsValid")
                        try self.saveAccount(email, first_name: first_name, last_name: last_name, image: image_url, token: token, client: client)
                    } else {
                        print("Error: Invalid JSON")
                        success = false
                    }
                } catch let error {
                    print("Error: \(error)")
                    success = false
                }
            }
        } catch let error {
            print("Error: \(error)")
            success = false
        }
        
        return success
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
        
        dispatch_async(dispatch_get_main_queue(), {
            sender.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func displayLoading(view: UIView) -> UIActivityIndicatorView {
//        let overlay = UIView(frame: view.bounds)
//        overlay.backgroundColor = UIColor.grayColor()
        
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        
//        loading.center = overlay.center
        loading.center = view.center
        loading.hidesWhenStopped = true
        loading.activityIndicatorViewStyle = .Gray
        dispatch_async(dispatch_get_main_queue(), {
//            overlay.addSubview(loading)
//            view.addSubview(overlay)
            view.addSubview(loading)
        })
        loading.startAnimating()
        
        return loading
    }
}

let server = Server()