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

let SERVER_ADDRESS = "popart-app.com"
//let SERVER_ADDRESS = "192.168.0.175"
//let SERVER_PORT = 5100
let SERVER_PORT = 5200

class Server {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var shouldSend = false
    
    let http_url = "http://\(SERVER_ADDRESS):\(SERVER_PORT)/"
    
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    var squareSize = 200
    var focusSquare: FocusSquareView?
    
    var test: Session?
    
    init() {
//        test = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: self.managedObjectContext!) as? Session
//        
//        test!.email = "ricardo.krieg@gmail.com"
//        test!.session = "asdfasdf"
//        test!.name = "Ricardo Franco"
//        
//        do {
//            try self.managedObjectContext!.save()
//        } catch _ {
//        }
    }
    
    func requireSignedIn(caller: String) {
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
                let rootController = storyboard.instantiateViewControllerWithIdentifier(rootControllerIdentifier!)
                window.rootViewController = rootController
            }
        }
    }
    
    func userSignedIn() -> Bool {
        let session = getSession()
        
        return session != nil
    }
    
    func getSession() -> Session? {
        var session: Session? = nil
        let fetchRequest = NSFetchRequest(entityName: "Session")
        
        do {
            if let fetchResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [Session] {
                if fetchResults.count > 0 {
                    session = fetchResults[0]
                }
            }
        } catch _ {
        }
        
        
        return session
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