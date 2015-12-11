//
//  ContactViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 26/10/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
    
    var tapGesture: UITapGestureRecognizer?
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        let subject = subjectTextField!.text
        let content = contentTextView!.text
        
        server.doCreateTicket(self, subject: subject!, content: content!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        subjectTextField.delegate = self
        
        contentTextView.text = "Message"
        contentTextView.textColor = UIColor.lightGrayColor()
        contentTextView.delegate = self
        
        tapGesture = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        tapGesture!.enabled = false
        view.addGestureRecognizer(tapGesture!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromContactToSendingPicture" {
            if pickedImage != nil {
                let destination = segue.destinationViewController as! SendingPictureViewController
                destination.pickedImage = pickedImage
                pickedImage = nil
            }
            
            server.shouldSend = true
        } else if segue.identifier == "fromContactToMenu" {
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
        pickedImage = image
        
        dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("fromContactToSendingPicture", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        tapGesture?.enabled = true
        
        return true
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
        subjectTextField.resignFirstResponder()
        contentTextView.resignFirstResponder()
        
        tapGesture?.enabled = false
    }

}
