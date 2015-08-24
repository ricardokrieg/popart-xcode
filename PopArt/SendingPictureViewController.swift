//
//  SendingPictureViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 22/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit

class SendingPictureViewController: UIViewController {
    @IBOutlet weak var imageContainer: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let url = NSURL(string: "http://www.vangoghbikes.com/wp-content/uploads/2014/12/Johannes_Vermeer_1632-1675_-_The_Girl_With_The_Pearl_Earring_1665-2.jpg") {
            if let data = NSData(contentsOfURL: url){
                //imageContainer.contentMode = UIViewContentMode.ScaleAspectFit
                imageContainer.image = UIImage(data: data)
                let imageData = UIImageJPEGRepresentation(imageContainer.image, 0.5)
                let imageDataBase64 = imageData.base64EncodedStringWithOptions(.allZeros)
//                let imageDataString = NSString(data: imageData, encoding: NSUTF8StringEncoding)
//                println(imageDataBase64)
                
                server.send("identify")
                if let response = server.read() {
                    if response == "ok" {
                        server.send("\(imageDataBase64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)):\(imageDataBase64)")
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
