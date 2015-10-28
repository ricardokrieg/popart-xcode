//
//  ResultModalViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 17/09/15.
//  Copyright (c) 2015 Netronian Inc. All rights reserved.
//

import UIKit

class ResultModalViewController: UIViewController {

    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultTitle: UILabel!
    @IBOutlet weak var resultDescriptionL1: UILabel!
    @IBOutlet weak var resultDescriptionL2: UILabel!
    @IBOutlet weak var resultDescriptionL3: UILabel!
    
    var result: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        if result != nil {
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(result!, options: [])
            
            let result_image_url = json?["image_url"] as? String?
            let result_title = json?["title"] as? String?
            let result_description_l1 = json?["description_l1"] as? String?
            let result_description_l2 = json?["description_l2"] as? String?
            let result_description_l3 = json?["description_l3"] as? String?
            
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
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromResultModalToResult" {
            let destination = segue.destinationViewController as! ResultViewController
            destination.result = result
            destination.saveToHistory = false
        }
    }
}
