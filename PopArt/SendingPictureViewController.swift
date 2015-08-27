//
//  SendingPictureViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 22/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit
import CoreLocation

class SendingPictureViewController: UIViewController {
    @IBOutlet weak var imageContainer: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var pickedImage: UIImage?
    var result: NSData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if pickedImage != nil {
            imageContainer.contentMode = .ScaleAspectFit
            imageContainer.image = pickedImage
        } else {
            if let url = NSURL(string: "http://www.vangoghbikes.com/wp-content/uploads/2014/12/Johannes_Vermeer_1632-1675_-_The_Girl_With_The_Pearl_Earring_1665-2.jpg") {
                if let data = NSData(contentsOfURL: url){
                    //imageContainer.contentMode = UIViewContentMode.ScaleAspectFit
                    imageContainer.image = UIImage(data: data)
                    let imageData = UIImageJPEGRepresentation(imageContainer.image, 0.5)
                    let imageDataBase64 = imageData.base64EncodedStringWithOptions(.allZeros)
                    // let imageDataString = NSString(data: imageData, encoding: NSUTF8StringEncoding)
                    // println(imageDataBase64)
                    // server.send("\(imageDataBase64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)):\(imageDataBase64)")
                }
            }
        }
        
//        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
        
        var currentLocation: CLLocation?
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
                currentLocation = locationManager.location
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if self.imageContainer.image != nil {
                let imageData = UIImageJPEGRepresentation(self.imageContainer.image, 0.5)
                let imageDataBase64 = imageData.base64EncodedStringWithOptions(.allZeros)
            
                server.send("identify")
            
                if let response = server.read() {
                    if response == "ok" {
                        if currentLocation != nil {
                            server.send("geolocation")
            
                            if let response = server.read() {
                                if response == "ok" {
                                    server.send(JSON([currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude].description).stringValue)
                                
                                    server.read()
                                }
                            }
                        }
                    
                        server.send("image-data")
                    
                        if let response = server.read() {
                            if response == "ok" {
                                server.send("\(imageDataBase64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)):\(imageDataBase64)")
                            
                                if let response = server.read() {
                                    if response == "acknowledge" {
                                        server.send("done")
                                    
                                        if let response = server.read() {
//                                            self.result = JSON(response)
//                                            let teste = JSON(response)
//                                            println(teste[0].string)
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
            
            dispatch_async(dispatch_get_main_queue()) {}
        }
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
                result = nil
            }
        }
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
