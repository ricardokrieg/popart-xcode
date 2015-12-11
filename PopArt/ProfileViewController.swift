//
//  ProfileViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 28/10/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let account = Account.load() {
            if server.tokenIsValid(account) {
                firstNameLabel!.text = account.first_name
                lastNameLabel!.text = account.last_name
                emailLabel!.text = account.uid
            
                if account.image != "" {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        if let url = NSURL(string: account.image) {
                            if let data = NSData(contentsOfURL: url){
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.imageView.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                } else {
                    imageView.image = UIImage(named: "splash")
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromProfileToMenu" {
            if let controller = segue.destinationViewController as UIViewController? {
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController!.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
                let width = min(self.view.frame.width-20, 320)
                controller.preferredContentSize = CGSize(width: width, height: 140)
            }
        }
    }
        
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

}
