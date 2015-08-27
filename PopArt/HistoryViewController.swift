//
//  HistoryViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 27/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var paintings = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return paintings.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
            
            let painting = paintings[indexPath.row]
            cell.textLabel!.text = painting.valueForKey("result_title") as? String
            
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
