//
//  HistoryViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 29/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var result: NSData?
    var paintings = [NSManagedObject]()

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
            
            self.tableView.reloadData()
            
            println("History cleared")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

        cell.locationAreaLabel!.text = painting.valueForKey("location_area") as? String
        cell.locationCountryLabel!.text = painting.valueForKey("location_country") as? String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let result_date = painting.valueForKey("date") as? NSDate {
            cell.dateLabel!.text = dateFormatter.stringFromDate(result_date)
        }
        
        if let image_url = painting.valueForKey("image_url") as? String {
            if let url = NSURL(string: image_url) {
                if let data = NSData(contentsOfURL: url){
                    cell.imageContainer!.contentMode = .ScaleAspectFit
                    cell.imageContainer!.image = UIImage(data: data)
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

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromHistoryToResult" {
            if result != nil {
                let destination = segue.destinationViewController as! ResultViewController
                destination.result = result
                destination.saveToHistory = false
                self.result = nil
            }
        }
    }

}
