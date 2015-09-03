//
//  MenuViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 02/09/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var page_url: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromMenuToPage" {
            let destination = segue.destinationViewController as! PageViewController
            destination.url = page_url
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.icon.image = UIImage(named: "settings")
            cell.label.text = "Settings"
        case 1:
            cell.icon.image = UIImage(named: "profile")
            cell.label.text = "Profile"
        case 2:
            cell.icon.image = UIImage(named: "about")
            cell.label.text = "About"
        default:
            println("Invalid menu cell")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            performSegueWithIdentifier("fromMenuToSettings", sender: nil)
        case 2:
            page_url = "http://popart-app.com/static/about-us.html"
            performSegueWithIdentifier("fromMenuToPage", sender: nil)
        default:
            println("actionSheet without action \(indexPath.row)")
        }
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
