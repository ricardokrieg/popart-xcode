//
//  ResultViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 25/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit
import CoreData

class ResultViewController: UIViewController {
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultTitle: UILabel!
    @IBOutlet weak var resultDescriptionL1: UILabel!
    @IBOutlet weak var resultDescriptionL2: UILabel!
    @IBOutlet weak var resultDescriptionL3: UILabel!
    
    var result: NSData?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if result != nil {
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(result!, options: nil, error: nil)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity =  NSEntityDescription.entityForName("Painting", inManagedObjectContext: managedContext)
            let painting = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            if let result_image_url = json?["image_url"] as? String? {
                painting.setValue(result_image_url, forKey: "result_image_url")
                
                if let url = NSURL(string: result_image_url!) {
                    if let data = NSData(contentsOfURL: url){
                        resultImage.contentMode = .ScaleAspectFit
                        resultImage.image = UIImage(data: data)
                    }
                }
            }
            
            if let result_query_image_url = json?["query_image_url"] as? String? {
                painting.setValue(result_query_image_url, forKey: "image_url")
            }
            
            if let result_title = json?["title"] as? String? {
                painting.setValue(result_title, forKey: "result_title")
            }
            
            if let result_description_l1 = json?["description_l1"] as? String? {
                painting.setValue(result_description_l1, forKey: "result_description_l1")
            }
            
            if let result_description_l2 = json?["description_l2"] as? String? {
                painting.setValue(result_description_l2, forKey: "result_description_l2")
            }
            
            if let result_description_l3 = json?["description_l3"] as? String? {
                painting.setValue(result_description_l3, forKey: "result_description_l3")
            }
            
            resultTitle.text = painting.valueForKey("result_title") as? String
            resultDescriptionL1.text = painting.valueForKey("result_description_l1") as? String
            resultDescriptionL2.text = painting.valueForKey("result_description_l2") as? String
            resultDescriptionL3.text = painting.valueForKey("result_description_l3") as? String
            
            if let result_success = json?["success"] as? Bool? {
                if result_success == true {
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
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
