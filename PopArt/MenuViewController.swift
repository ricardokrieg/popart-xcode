//
//  MenuViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 02/09/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var page_url: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        self.view.superview?.layer.cornerRadius = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            cell.label.font = UIFont(name: "MinionPro", size: 17)
        case 1:
            cell.icon.image = UIImage(named: "profile")
            cell.label.text = "Profile"
            cell.label.font = UIFont(name: "MinionPro", size: 17)
        case 2:
            cell.icon.image = UIImage(named: "about")
            cell.label.text = "About"
            cell.label.font = UIFont(name: "MinionPro", size: 17)
        default:
            print("Invalid menu cell")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            performSegueWithIdentifier("fromMenuToSettings", sender: nil)
        case 1:
            performSegueWithIdentifier("fromMenuToProfile", sender: nil)
        case 2:
            page_url = server.aboutUsUrl
            performSegueWithIdentifier("fromMenuToPage", sender: nil)
        default:
            print("actionSheet without action \(indexPath.row)")
        }
    }

}
