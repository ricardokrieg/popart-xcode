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
    
    var paintings = [NSManagedObject]()

    @IBAction func clearButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Painting")
        
        var error: NSError?
        
        var fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        fetchedResults!.removeAll(keepCapacity: false)
        
        self.tableView.reloadData()
        
        println("History cleared")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.registerClass(HistoryTableViewCell.self, forCellReuseIdentifier: "Cell")
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
        
//        cell.textLabel!.text = painting.valueForKey("result_title") as? String
        cell.titleLabel!.text = painting.valueForKey("result_title") as? String
        cell.descriptionLabel!.text = painting.valueForKey("result_description_l1") as? String
        
        let image_url = painting.valueForKey("image_url") as? String

        if let url = NSURL(string: image_url!) {
            if let data = NSData(contentsOfURL: url){
                cell.imageContainer!.contentMode = .ScaleAspectFit
                cell.imageContainer!.image = UIImage(data: data)
            }
        }
        
        return cell
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
