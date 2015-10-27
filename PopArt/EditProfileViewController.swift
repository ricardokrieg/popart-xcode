//
//  EditProfileViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 26/10/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
    
    var tapGesture: UITapGestureRecognizer?
    
    var imageChanged = false
    
    @IBAction func imageButtonClicked(sender: AnyObject) {
        pickedImage = nil
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func updateButtonClicked(sender: AnyObject) {
        let first_name = firstNameTextField!.text
        let last_name = lastNameTextField!.text
        let email = emailTextField!.text
        let password = passwordTextField!.text
        
        var image: UIImage? = nil
        if imageChanged {
            image = imageButton.imageForState(.Normal)
        }
        
        server.doUpdateProfile(self, first_name: first_name!, last_name: last_name!, email: email!, password: password!, image: image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapGesture!.enabled = false
        view.addGestureRecognizer(tapGesture!)
    }
    
    override func viewWillAppear(animated: Bool) {
        imageChanged = false
        
        if let account = Account.load() {
            if server.tokenIsValid(account) {
                firstNameTextField!.text = account.first_name
                lastNameTextField!.text = account.last_name
                emailTextField!.text = account.uid
                passwordTextField!.text = ""
                
                if account.image != "" {
                    imageButton.setTitle("", forState: .Normal)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        if let url = NSURL(string: account.image) {
                            if let data = NSData(contentsOfURL: url){
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.imageButton.setImage(UIImage(data: data)!.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
                                }
                            }
                        }
                    }
                } else {
                    imageButton.setTitle("Upload image", forState: .Normal)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromEditProfileToSendingPicture" {
            if pickedImage != nil {
                let destination = segue.destinationViewController as! SendingPictureViewController
                destination.pickedImage = pickedImage
                pickedImage = nil
            }
            
            server.shouldSend = true
        } else if segue.identifier == "fromEditProfileToMenu" {
            if let controller = segue.destinationViewController as UIViewController? {
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController!.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
                let width = min(self.view.frame.width-20, 320)
                controller.preferredContentSize = CGSize(width: width, height: 140)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        pickedImage = image
        
        dismissViewControllerAnimated(true, completion: {
//            self.performSegueWithIdentifier("fromEditProfileToSendingPicture", sender: nil)
            self.imageChanged = true
            self.imageButton.setImage(image.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
