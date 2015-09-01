//
//  PageViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 31/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var url: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
