//
//  ResetPasswordViewController.swift
//  PopsArt
//
//  Created by Ricardo Franco on 13/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var iAgreeLabel: TTTAttributedLabel!
    
    @IBAction func resetButtonClicked(sender: AnyObject) {
        server.doResetPassword(self, email: emailField.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
