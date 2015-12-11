//
//  SettingsTableViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 31/08/15.
//  Copyright © 2015 Art Catch. All rights reserved.
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
            case 0:
                performSegueWithIdentifier("fromSettingsToEditProfile", sender: nil)
            default:
                print("Unhandled row: \(indexPath.row)")
            }
        case 1:
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("fromSettingsToContact", sender: nil)
            case 1:
                page_url = server.privacyPolicyUrl
                performSegueWithIdentifier("fromSettingsToPage", sender: nil)
            case 2:
                page_url = server.termsOfServiceUrl
                performSegueWithIdentifier("fromSettingsToPage", sender: nil)
            default:
                print("Unhandled row: \(indexPath.row)")
            }
        case 2:
            switch indexPath.row {
            case 0:
                server.doSignOut()
                server.authenticateUser("SettingsTableViewController", checkToken: false)
            default:
                print("Unhandled row: \(indexPath.row)")
            }
        default:
            print("Unhandled section: \(indexPath.section)")
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UIView()
            
            let label = UILabel()
            label.text = "Version 1.1.0"
            label.font = UIFont(name: "MinionPro", size: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .Center
            
            label.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250))
            
            let image = UIImageView()
            image.image = UIImage(named: "logo")
            image.translatesAutoresizingMaskIntoConstraints = false
            
            image.addConstraint(NSLayoutConstraint(item: image, attribute: .Width, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50))
            image.addConstraint(NSLayoutConstraint(item: image, attribute: .Height, relatedBy: .Equal,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 43))
            
            view.addSubview(label)
            view.addSubview(image)
            
            let labelXConstraint = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
            let labelYConstraint = NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
            let imageXConstraint = NSLayoutConstraint(item: image, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
            let imageYConstraint = NSLayoutConstraint(item: image, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
            
            view.addConstraint(labelXConstraint)
            view.addConstraint(labelYConstraint)
            view.addConstraint(imageXConstraint)
            view.addConstraint(imageYConstraint)
            
            return view
        }
        
        return super.tableView(tableView, viewForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 80
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
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
