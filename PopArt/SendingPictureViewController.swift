//
//  SendingPictureViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 22/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
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
        
        self.statusLabel.text = "Searching"
        
        // Display capture/picked image
        
        if pickedImage != nil {
            imageContainer.contentMode = .ScaleAspectFit
            imageContainer.image = compressImage(pickedImage!)
        }
        
        // Get location
        
        if server.location != nil {
            print("User location: (\(server.location!.coordinate.latitude), \(server.location!.coordinate.longitude))")
        } else {
            print("User didnt allow location")
        }
        
        // Send to server
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if self.imageContainer.image != nil {
                let imageData = UIImageJPEGRepresentation(self.imageContainer.image!, 0.5)
                
                var message_lat = ""
                var message_lng = ""
                var message_location_area = ""
                var message_location_country = ""
                
                if server.location != nil {
                    message_lat = String(stringInterpolationSegment: server.location!.coordinate.latitude)
                    message_lng = String(stringInterpolationSegment: server.location!.coordinate.longitude)
                }
                
                if server.placemark != nil {
                    if let msg_location_area = server.placemark!.locality {
                        message_location_area = String(msg_location_area)
                    }
                    
                    if let msg_location_country = server.placemark!.country {
                        message_location_country = String(msg_location_country)
                    }
                }
                
                let params: Dictionary<String, AnyObject> = ["image": Upload(data: imageData!, fileName: "upload.jpg", mimeType: "image/jpeg"), "lat": message_lat, "lng": message_lng, "location_area": message_location_area, "location_country": message_location_country]
                
                server.ping(self)
                
                do {
                    let opt = try HTTP.POST(server.http_url, parameters: params)
                
                    opt.start { response in
                        if let err = response.error {
                            print("error: \(err.localizedDescription)")
                            return //also notify app of failure as needed
                        }
                    
                        let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                        print("response: \(str)") //prints the HTML of the page
                        
                        self.result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("fromSendingPictureToResult", sender: nil)
                        }
                    }
                } catch let error {
                    print("got an error creating the request: \(error)")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.text = "Searching"
                }
            }
        }
        
        server.shouldSend = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        return UIImage(data: imageData!)!
    }

}
