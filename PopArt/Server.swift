//
//  Server.swift
//  PopsArt
//
//  Created by Netronian Inc. on 17/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

//        https://github.com/swiftsocket/SwiftSocket
//        var client:TCPClient = TCPClient(addr: "192.168.0.175", port: 5100)
//        var (success,errmsg)=client.connect(timeout: 10)
//        var (success,errmsg)=client.send(str:"GET / HTTP/1.0\n\n" )
//        socket.send(data:[Int8])
//        var data=client.read(1024*10) //return optional [Int8]
//        var (success,errormsg)=client.close()

import Foundation
import CoreLocation
import SwiftHTTP

let SERVER_ADDRESS = "popart-app.com"
//let SERVER_ADDRESS = "192.168.0.175"
//let SERVER_PORT = 5100
let SERVER_PORT = 5200

class Server {
    var shouldSend = false
    
    let http_url = "http://\(SERVER_ADDRESS):\(SERVER_PORT)/"
    
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    var squareSize = 200
    var focusSquare: FocusSquareView?
    
    init() {}
    
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