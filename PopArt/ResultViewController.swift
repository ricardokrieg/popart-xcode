//
//  ResultViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 25/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import UIKit
import CoreData
import Social
import MessageUI
import AssetsLibrary

class ResultViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultTitle: UILabel!
    @IBOutlet weak var resultDescriptionL1: UILabel!
    @IBOutlet weak var resultDescriptionL2: UILabel!
    @IBOutlet weak var resultDescriptionL3: UILabel!
    
    var result: NSData?
    var saveToHistory:Bool = false
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        var textToShare = ""
        if let title = resultTitle {
            textToShare = "User A, found \(title.text!) with PopArt App <linked to App Store>"
        }
        var imageToShare:UIImage? = nil
        if let image = resultImage?.image {
            imageToShare = image
        }
        
        let objectsToShare = [textToShare, imageToShare as! AnyObject]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func facebookButtonClicked(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            if let title = resultTitle {
                facebookSheet.setInitialText("User A, found \(title.text!) with PopArt App <linked to App Store>")
            }
            
            facebookSheet.addImage(resultImage?.image)
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func twitterButtonClicked(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            if let title = resultTitle {
                twitterSheet.setInitialText("User A, found \(title.text!) with PopArt App <linked to App Store>")
            }
            
            twitterSheet.addImage(resultImage?.image)
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func googlePlusButtonClicked(sender: AnyObject) {
        let instagramURL = NSURL(string: "instagram://app")!
        if UIApplication.sharedApplication().canOpenURL(instagramURL) {
            let library = ALAssetsLibrary() ;
            
            // Create a bitmap graphics context
            let newImage = self.resultImage.image!.imageWithNewSize(CGSizeMake(640, 640))
            
            library.writeImageToSavedPhotosAlbum(newImage.CGImage, metadata:nil , completionBlock: { ( asseturl: NSURL! , error: NSError!) -> Void in
                
                let escapedString = asseturl.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
                
                      let instagramURL = NSURL(string: "instagram://library?AssetPath=\(escapedString)");
                
                    UIApplication.sharedApplication().openURL(instagramURL!)
            })
        } else {
            print("instagram not found")

            let alertCont = UIAlertController(title: "Instagram", message: "Hello, You need Instagram app to be downloaded in to your device for share image on Instagram.", preferredStyle: UIAlertControllerStyle.Alert);
            alertCont.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertCont, animated: true, completion: nil);
        }
    }
    
    @IBAction func mailButtonClicked(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mc:MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject((resultTitle?.text)!)
            UIImageJPEGRepresentation((resultImage?.image)!, 1)
            
            mc.addAttachmentData(UIImageJPEGRepresentation((resultImage?.image)!, 1)!, mimeType: "image/jpeg", fileName: "image.jpeg")
            self.presentViewController(mc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Email account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        if result != nil {
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
            
            let result_success = json?["success"] as? Bool
            let result_image_url = json?["image_url"] as? String?
            let result_query_image_url = json?["query_image_url"] as? String?
            let result_thumb_image_url = json?["thumb_image_url"] as? String?
            let result_title = json?["title"] as? String?
            let result_description_l1 = json?["description_l1"] as? String?
            let result_description_l2 = json?["description_l2"] as? String?
            let result_description_l3 = json?["description_l3"] as? String?
            let result_detailed_description = json?["detailed_description"] as? String?
            let result_location_area = json?["location_area"] as? String?
            let result_location_country = json?["location_country"] as? String?
            
            if (result_success == true) {
                shareButton.enabled = true
                shareButton.hidden = false
            } else {
                shareButton.enabled = false
                shareButton.hidden = true
            }
            
            if result_image_url != nil {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    if let url = NSURL(string: result_image_url!!) {
                        if let data = NSData(contentsOfURL: url){
                            dispatch_async(dispatch_get_main_queue()) {
                                self.resultImage.contentMode = .ScaleAspectFit
                                self.resultImage.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
            
            if result_title != nil {
                resultTitle.text = result_title!
            }
            
            if result_description_l1 != nil {
                resultDescriptionL1.text = result_description_l1!
            }
            
            if result_description_l2 != nil {
                resultDescriptionL2.text = result_description_l2!
            }
            
            if result_description_l3 != nil {
                resultDescriptionL3.text = result_description_l3!
            }
            
            if saveToHistory {
                saveToHistory = false
                
                if let result_success = json?["success"] as? Bool? {
                    if result_success == true {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let managedContext = appDelegate.managedObjectContext!
                        
                        let entity =  NSEntityDescription.entityForName("Painting", inManagedObjectContext: managedContext)
                        let painting = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                        
                        if result_query_image_url != nil {
                            painting.setValue(result_query_image_url!, forKey: "image_url")
                        }
                        
                        if result_image_url != nil {
                            painting.setValue(result_image_url!, forKey: "result_image_url")
                        }
                        
                        if result_thumb_image_url != nil {
                            painting.setValue(result_thumb_image_url!, forKey: "thumb_image_url")
                        }
                        
                        if result_title != nil {
                            painting.setValue(result_title!, forKey: "result_title")
                        }
                        
                        if result_description_l1 != nil {
                            painting.setValue(result_description_l1!, forKey: "result_description_l1")
                        }
                        
                        if result_description_l2 != nil {
                            painting.setValue(result_description_l2!, forKey: "result_description_l2")
                        }
                        
                        if result_description_l3 != nil {
                            painting.setValue(result_description_l3!, forKey: "result_description_l3")
                        }
                        
                        if result_detailed_description != nil {
                            painting.setValue(result_detailed_description!, forKey: "result_detailed_description")
                        }
                        
                        if result_location_area != nil {
                            painting.setValue(result_location_area!, forKey: "location_area")
                        }
                        
                        if result_location_country != nil {
                            painting.setValue(result_location_country!, forKey: "location_country")
                        }
                        
                        painting.setValue(NSDate(), forKey: "date")
                        painting.setValue(result!, forKey: "json")
                        
                        var error: NSError?
                        do {
                            try managedContext.save()
                        } catch let error1 as NSError {
                            error = error1
                            print("Could not save \(error), \(error?.userInfo)")
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromResultToMenu" {
            if let controller = segue.destinationViewController as UIViewController? {
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController!.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
                controller.preferredContentSize = CGSize(width: self.view.frame.width-20, height: 140)
            }
        } else if segue.identifier == "fromResultToResultModal" {
            let destination = segue.destinationViewController as! ResultModalViewController
            destination.result = self.result
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

extension UIImage {
    func imageWithNewSize(newSize:CGSize) ->UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return newImage
    }
}


