//
//  SignInViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 06/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func goToSignIn(segue: UIStoryboardSegue) {}
    
    @IBAction func loginButtonClicked(sender: AnyObject) {
        server.doSignIn(self, email: emailTextField.text!, password: passwordTextField.text!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        server.authenticateUser("SignInViewController", checkToken: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
