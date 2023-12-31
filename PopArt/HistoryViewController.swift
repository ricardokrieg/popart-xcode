//
//  HistoryViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 29/08/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    
    var result: NSData?
    var paintings = [NSManagedObject]()
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?

    @IBAction func clearButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
    
        let fetchRequest = NSFetchRequest(entityName: "Painting")
        
        var fetchedResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject]
        
        if let _ = fetchedResults {
            for history in fetchedResults! {
                managedContext.deleteObject(history)
            }
            
            fetchedResults!.removeAll(keepCapacity: false)
            
            do {
                try managedContext.save()
            } catch _ {
            }
            
            self.paintings = [NSManagedObject]()
            self.tableView.reloadData()
            
            if paintings.isEmpty {
                let emptyHistoryLabel = UILabel.init(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
                emptyHistoryLabel.text = "Empty History"
                emptyHistoryLabel.textAlignment = .Center
                emptyHistoryLabel.sizeToFit()
                
                tableView.backgroundView = emptyHistoryLabel
                tableView.separatorStyle = .None
            }
            
            print("History cleared")
        }
    }
    
//    @IBAction func selectImageButtonClicked(sender: AnyObject) {
//        pickedImage = nil
//        
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .PhotoLibrary
//        
//        presentViewController(imagePicker, animated: true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Painting")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            
            if let results = fetchedResults {
                paintings = results
                
                print("History: \(paintings.count) items")
            } else {
                print("Could not fetch history")
            }
        } catch let error {
            print("Error loading history: \(error)")
        }
        
        if paintings.isEmpty {
            let emptyHistoryLabel = UILabel.init(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
            emptyHistoryLabel.text = "Empty History"
            emptyHistoryLabel.textAlignment = .Center
            emptyHistoryLabel.sizeToFit()
            
            tableView.backgroundView = emptyHistoryLabel
            tableView.separatorStyle = .None
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paintings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! HistoryTableViewCell
        
        let painting = paintings[indexPath.row]
        
        cell.titleLabel!.text = painting.valueForKey("result_title") as? String
        cell.descriptionLabel!.text = painting.valueForKey("result_detailed_description") as? String

        if let location_area_text = painting.valueForKey("location_area") as? String {
            cell.locationAreaLabel!.text = location_area_text.uppercaseString
        }
        if let location_country_text = painting.valueForKey("location_country") as? String {
            cell.locationCountryLabel!.text = location_country_text.uppercaseString
        }
        
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
        return 80.0
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
            self.performSegueWithIdentifier("fromHistoryToSendingPicture", sender: nil)
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
