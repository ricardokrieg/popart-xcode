//
//  HistoryViewController.swift
//  PopArt
//
//  Created by Netronian Inc. on 29/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    
    var result: NSData?
    var paintings = [NSManagedObject]()
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?

    @IBAction func clearButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
    
        let fetchRequest = NSFetchRequest(entityName: "Painting")
        
        var fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject]
        
        if let results = fetchedResults {
            for history in fetchedResults! {
                managedContext.deleteObject(history)
            }
            
            fetchedResults!.removeAll(keepCapacity: false)
            
            managedContext.save(nil)
            
            self.paintings = [NSManagedObject]()
            self.tableView.reloadData()
            
            println("History cleared")
        }
    }
    
    @IBAction func selectImageButtonClicked(sender: AnyObject) {
        pickedImage = nil
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Painting")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            paintings = results
            
            println("History: \(paintings.count) items")
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paintings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! HistoryTableViewCell
        
        let painting = paintings[indexPath.row]
        
        cell.titleLabel!.text = painting.valueForKey("result_title") as? String
        cell.descriptionLabel!.text = painting.valueForKey("result_description_l1") as? String

//        cell.locationAreaLabel!.text = painting.valueForKey("location_area") as? String
//        cell.locationCountryLabel!.text = painting.valueForKey("location_country") as? String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let result_date = painting.valueForKey("date") as? NSDate {
            cell.dateLabel!.text = dateFormatter.stringFromDate(result_date)
        }
        
        if let image_url = painting.valueForKey("thumb_image_url") as? String {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if let url = NSURL(string: image_url) {
                    if let data = NSData(contentsOfURL: url){
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.imageContainer!.contentMode = .ScaleAspectFit
                            cell.imageContainer!.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let painting = paintings[indexPath.row]
        
        result = painting.valueForKey("json") as? NSData
        performSegueWithIdentifier("fromHistoryToResult", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromHistoryToResult" {
            if result != nil {
                let destination = segue.destinationViewController as! ResultViewController
                destination.result = result
                destination.saveToHistory = false
                self.result = nil
            }
        } else if segue.identifier == "fromHistoryToSendingPicture" {
            if pickedImage != nil {
                let destination = segue.destinationViewController as! SendingPictureViewController
                destination.pickedImage = pickedImage
                pickedImage = nil
            }
            
            server.shouldSend = true
        } else if segue.identifier == "fromHistoryToMenu" {
            if let controller = segue.destinationViewController as? UIViewController {
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
            self.performSegueWithIdentifier("fromHistoryToSendingPicture", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
}
