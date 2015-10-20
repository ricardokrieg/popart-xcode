//
//  SettingsTableViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 31/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    var page_url: String?
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        tableView.registerClass(HistoryTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                server.doSignOut()
                server.authenticateUser("SettingsTableViewController")
            default:
                print("Unhandled row: \(indexPath.row)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                page_url = "http://popart-app.com/static/help-center.html"
                performSegueWithIdentifier("fromSettingsToPage", sender: nil)
            case 1:
                page_url = "http://popart-app.com/static/privacy-policy.html"
                performSegueWithIdentifier("fromSettingsToPage", sender: nil)
            case 2:
                page_url = "http://popart-app.com/static/terms-of-use.html"
                performSegueWithIdentifier("fromSettingsToPage", sender: nil)
            default:
                print("Unhandled row: \(indexPath.row)")
            }
        default:
            print("Unhandled section: \(indexPath.section)")
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromSettingsToPage" {
            let destination = segue.destinationViewController as! PageViewController
            destination.url = page_url
        } else if segue.identifier == "fromSettingsToSendingPicture" {
            if pickedImage != nil {
                let destination = segue.destinationViewController as! SendingPictureViewController
                destination.pickedImage = pickedImage
                pickedImage = nil
            }
            
            server.shouldSend = true
        } else if segue.identifier == "fromSettingsToMenu" {
            if let controller = segue.destinationViewController as UIViewController? {
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController!.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
                controller.preferredContentSize = CGSize(width: self.view.frame.width-20, height: 140)
            }
        }
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        pickedImage = image
        
        dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("fromPageToSendingPicture", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
