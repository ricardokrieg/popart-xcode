//
//  SignInViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 06/10/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var tapGesture: UITapGestureRecognizer?
    
    @IBAction func goToSignIn(segue: UIStoryboardSegue) {}
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        server.doSignIn(self, email: emailTextField.text!, password: passwordTextField.text!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapGesture!.enabled = false
        view.addGestureRecognizer(tapGesture!)
        //server.doSignIn(self, email: "info@netronian.com", password: "admin123")
//        server.authenticateUser("SignInViewController", checkToken: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        tapGesture?.enabled = false
    }

}
