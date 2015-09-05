//
//  ResultViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 25/08/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import UIKit
import CoreData
import Social
import MessageUI

class ResultViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultTitle: UILabel!
    @IBOutlet weak var resultDescriptionL1: UILabel!
    @IBOutlet weak var resultDescriptionL2: UILabel!
    @IBOutlet weak var resultDescriptionL3: UILabel!
    
    var result: NSData?
    var saveToHistory:Bool = false

    @IBAction func facebookButtonClicked(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            if let title = resultTitle {
                facebookSheet.setInitialText("User A, found \(title.text!) with PopsArt App <linked to App Store>")
            }
            
            facebookSheet.addImage(resultImage?.image)
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func twitterButtonClicked(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            if let title = resultTitle {
                twitterSheet.setInitialText("User A, found \(title.text!) with PopsArt App <linked to App Store>")
            }
            
            twitterSheet.addImage(resultImage?.image)
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func googlePlusButtonClicked(sender: AnyObject) {
    }
    
    @IBAction func mailButtonClicked(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            var mc:MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(resultTitle?.text)
            UIImageJPEGRepresentation(resultImage?.image, 1)
            
            mc.addAttachmentData(UIImageJPEGRepresentation(resultImage?.image, 1), mimeType: "image/jpeg", fileName: "image.jpeg")
            //        self.showViewController(mc, sender: self)
            self.presentViewController(mc, animated: true, completion: nil)
        }else{
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Email account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if result != nil {
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(result!, options: nil, error: nil)
            
            let result_image_url = json?["image_url"] as? String?
            let result_query_image_url = json?["query_image_url"] as? String?
            let result_thumb_image_url = json?["thumb_image_url"] as? String?
            let result_title = json?["title"] as? String?
            let result_description_l1 = json?["description_l1"] as? String?
            let result_description_l2 = json?["description_l2"] as? String?
            let result_description_l3 = json?["description_l3"] as? String?
            let result_location_area = json?["location_area"] as? String?
            let result_location_country = json?["location_country"] as? String?
            
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
                
//                dispatch_async(dispatch_get_main_queue()) {}
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
                    //if result_success == true {
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
                        
                        if result_location_area != nil {
                            painting.setValue(result_location_area!, forKey: "location_area")
                        }
                        
                        if result_location_country != nil {
                            painting.setValue(result_location_country!, forKey: "location_country")
                        }
                        
                        painting.setValue(NSDate(), forKey: "date")
                        painting.setValue(result!, forKey: "json")
                        
                        var error: NSError?
                        if !managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                    //}
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
