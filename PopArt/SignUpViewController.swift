//
//  SignUpViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 06/10/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class SignUpViewController: UIViewController, TTTAttributedLabelDelegate, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var iAgreeLabel: TTTAttributedLabel!
    
    var tapGesture: UITapGestureRecognizer?
    
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
        
        iAgreeLabel.addLinkToURL(NSURL(string: server.termsOfServiceUrl), withRange: termsOfServiceRange)
        iAgreeLabel.addLinkToURL(NSURL(string: server.privacyPolicyUrl), withRange: privacyPolicyRange)
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapGesture!.enabled = false
        view.addGestureRecognizer(tapGesture!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        print(url)
        UIApplication.sharedApplication().openURL(url)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        tapGesture?.enabled = true
        
        return true
    }
    
    // MARK: - UITapGestureRecognizer
    
    func hideKeyboard() {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        tapGesture?.enabled = false
    }

}
