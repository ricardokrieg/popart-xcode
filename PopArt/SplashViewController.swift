//
//  SplashViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 27/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        server.authenticateUser("SplashViewController", checkToken: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
