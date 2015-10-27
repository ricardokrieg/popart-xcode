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
        
        iAgreeLabel.linkAttributes = [kCTForegroundColorAttributeName : UIColor(red: 199.0/255, green: 42.0/255, blue: 47.0/255, alpha: 1.0)]
        iAgreeLabel.activeLinkAttributes = [NSForegroundColorAttributeName : UIColor(red: 199.0/255, green: 42.0/255, blue: 47.0/255, alpha: 1.0)]
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
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        print(url)
        UIApplication.sharedApplication().openURL(url)
    }

}
