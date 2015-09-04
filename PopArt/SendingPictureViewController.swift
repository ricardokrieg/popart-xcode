//
//  SendingPictureViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 22/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftHTTP

class SendingPictureViewController: UIViewController {
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var pickedImage: UIImage?
    var result: NSData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if !server.shouldSend { return }
        
        self.statusLabel.text = "Uploading"
        
        // Display capture/picked image
        
        if pickedImage != nil {
            imageContainer.contentMode = .ScaleAspectFit
            imageContainer.image = compressImage(pickedImage!)
//            imageContainer.image = pickedImage
        } else {
//            if let url = NSURL(string: "http://www.vangoghbikes.com/wp-content/uploads/2014/12/Johannes_Vermeer_1632-1675_-_The_Girl_With_The_Pearl_Earring_1665-2.jpg") {
//                if let data = NSData(contentsOfURL: url){
//                    imageContainer.contentMode = .ScaleAspectFit
//                    imageContainer.image = compressImage(UIImage(data: data)!)
//                }
//            }
        }
        
        // Get location
        
        if server.location != nil {
            println("User location: (\(server.location!.coordinate.latitude), \(server.location!.coordinate.longitude))")
        } else {
            println("User didnt allow location")
        }
        
        // Send to server
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if self.imageContainer.image != nil {
                let imageData = UIImageJPEGRepresentation(self.imageContainer.image, 1.0)
                let imageDataBase64 = imageData.base64EncodedStringWithOptions(.allZeros)
//                let imageDataString = NSString(data: imageData, encoding: NSUTF8StringEncoding)
                
                let message_code = "IDENTIFY64"
//                let message_code = "IDENTIFY"
                
                var message_lat = ""
                var message_lng = ""
                var message_location_area = ""
                var message_location_country = ""
                
                if server.location != nil {
                    message_lat = String(stringInterpolationSegment: server.location!.coordinate.latitude)
                    message_lng = String(stringInterpolationSegment: server.location!.coordinate.longitude)
//                    if let coordinate = server.location!.coordinate {
//                        message_lat = String(stringInterpolationSegment: coordinate.latitude)
//                        message_lng = String(stringInterpolationSegment: coordinate.longitude)
//                    }
                }
                
                if server.placemark != nil {
                    if let msg_location_area = server.placemark!.administrativeArea {
                        message_location_area = String(msg_location_area)
                    }
                    
                    if let msg_location_country = server.placemark!.country {
                        message_location_country = String(msg_location_country)
                    }
                }
                
                let message_size = imageDataBase64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                let message_data = imageDataBase64
//                let message_size = imageDataString!.length
//                let message_data = imageDataString
            
                let message = "\(message_code):\(message_lat):\(message_lng):\(message_location_area):\(message_location_country):\(message_size):\(message_data)"
                
//                server.connect()
//                server.send(message)
                
                let params: Dictionary<String, AnyObject> = ["param": "param1", "array": ["first array element","second","third"], "num": 23, "dict": ["someKey": "someVal"]]
                server.request.POST(server.http_url, parameters: params, completionHandler: {(response: HTTPResponse) in
                    
                    self.result = response.dataUsingEncoding(NSUTF8StringEncoding)
                    self.performSegueWithIdentifier("fromSendingPictureToResult", sender: nil)
                })
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.text = "Searching"
                }
                
//                if let response = server.read() {
//                    server.disconnect()
//                    
//                    self.result = response.dataUsingEncoding(NSUTF8StringEncoding)
//                    self.performSegueWithIdentifier("fromSendingPictureToResult", sender: nil)
//                }
                
                /*
                if false {
                server.send("identify")
            
                if let response = server.read() {
                    if response == "ok" {
//                        if currentLocation != nil {
//                            server.send("geolocation")
//            
//                            if let response = server.read() {
//                                if response == "ok" {
//                                    server.send(JSON([currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude].description).stringValue)
//                                
//                                    server.read()
//                                }
//                            }
//                        }
                    
                        server.send("image-data")
                    
                        if let response = server.read() {
                            if response == "ok" {
                                server.send("\(imageDataBase64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)):\(imageDataBase64)")
                            
                                if let response = server.read() {
                                    if response == "acknowledge" {
                                        server.send("done")
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.statusLabel.text = "Searching"
                                        }
                                    
                                        if let response = server.read() {
                                            server.disconnect()
                                            
                                            self.result = response.dataUsingEncoding(NSUTF8StringEncoding)
                                            self.performSegueWithIdentifier("fromSendingPictureToResult", sender: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    }
                }
                */
            }
            
            dispatch_async(dispatch_get_main_queue()) {}
        }
        
        server.shouldSend = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromSendingPictureToResult" {
            if result != nil {
                let destination = segue.destinationViewController as! ResultViewController
                destination.result = result
                destination.saveToHistory = true
                result = nil
            }
        }
    }
    
    func compressImage(image: UIImage) -> UIImage {
        var actualHeight = Double(image.size.height)
        var actualWidth = Double(image.size.width)
        let maxHeight = 600.0
        let maxWidth = 800.0
        var imgRatio = actualWidth/actualHeight
        let maxRatio = maxWidth/maxHeight
        let compressionQuality = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(Int(actualWidth)), CGFloat(Int(actualHeight)))
        UIGraphicsBeginImageContext(rect.size)
        
        image.drawInRect(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
