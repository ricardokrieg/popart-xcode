//
//  SignUpViewController.swift
//  PopsArt
//
//  Created by Ricardo Franco on 06/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SignUpViewController: UIViewController, TTTAttributedLabelDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var iAgreeLabel: TTTAttributedLabel!
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        server.doSignUp(self, email: emailTextField.text!, password: passwordTextField.text!, first_name: firstNameTextField.text!, last_name: lastNameTextField.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iAgreeLabel.delegate = self
        
        iAgreeLabel.linkAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]
        iAgreeLabel.activeLinkAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]
        iAgreeLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        
        let iAgreeLabelText:NSString = iAgreeLabel.text!
        
        let termsOfServiceRange = iAgreeLabelText.rangeOfString("Terms of Service")
        let privacyPolicyRange = iAgreeLabelText.rangeOfString("Privacy Policy")
        
        iAgreeLabel.addLinkToURL(NSURL(string: "http://popart-app.com/terms-of-service"), withRange: termsOfServiceRange)
        iAgreeLabel.addLinkToURL(NSURL(string: "http://popart-app.com/privacy-policy"), withRange: privacyPolicyRange)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
