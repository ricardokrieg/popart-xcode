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
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
    
    var tapGesture: UITapGestureRecognizer?
    var imageTapGesture: UITapGestureRecognizer?
    
    var imageChanged = false
    var comingFromImagePicker = false
    
    @IBAction func updateButtonClicked(sender: AnyObject) {
        let first_name = firstNameTextField!.text
        let last_name = lastNameTextField!.text
        let email = emailTextField!.text
        let password = passwordTextField!.text
        
        var image: UIImage? = nil
        if imageChanged {
            image = imageView.image
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
        
        imageView.userInteractionEnabled = true
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 2
//        imageView.layer.shadowColor = UIColor.blackColor().CGColor
//        imageView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        imageView.layer.shadowOpacity = 0.4
//        imageView.layer.shadowRadius = 5
        
        imageTapGesture = UITapGestureRecognizer(target: self, action: "openImageChooser")
        imageView.addGestureRecognizer(imageTapGesture!)
    }
    
    override func viewWillAppear(animated: Bool) {
        if comingFromImagePicker {
            comingFromImagePicker = false
            return
        }
        
        imageChanged = false
        
        if let account = Account.load() {
            if server.tokenIsValid(account) {
                firstNameTextField!.text = account.first_name
                lastNameTextField!.text = account.last_name
                emailTextField!.text = account.uid
                passwordTextField!.text = ""
                
                if account.image != "" {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        if let url = NSURL(string: account.image) {
                            if let data = NSData(contentsOfURL: url){
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.imageView.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                } else {
                    imageView.image = UIImage(named: "splash")
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
            self.imageView.contentMode = .ScaleAspectFill
            self.imageView.image = image
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
    
    func openImageChooser() {
        pickedImage = nil
        comingFromImagePicker = true
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

}
