//
//  ViewController.swift
//  PopArt
//
//  Created by Ricardo Franco on 14/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
    
    var page_url: String?
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var stillImageOutput : AVCaptureStillImageOutput?
    
    @IBAction func cameraButtonClicked(sender: UIButton) {
        println("Camera")
        
        if captureDevice == nil {
            performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
            return
        }
        
        println("camera: start")
        if let stillOutput = self.stillImageOutput {
            println("camera: stillOutput")
            // we do this on another thread so we don't hang the UI
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                println("camera: videoConnection")
                // find video connection
                var videoConnection : AVCaptureConnection?
                for connection in stillOutput.connections {
                    println("camera: connection")
                    // find a matching input port
                    for port in connection.inputPorts! {
                        println("camera: port")
                        // and matching type
                        if port.mediaType == AVMediaTypeVideo {
                            println("camera: port.mediaType break")
                            videoConnection = connection as? AVCaptureConnection
                            break
                        }
                    }
                    if videoConnection != nil {
                        println("camera: connection break")
                        break // for connection
                    }
                }
                
                if videoConnection != nil {
                    println("camera: videoConnection not nil")
                    // found the video connection, let's get the image
                    stillOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                        (imageSampleBuffer:CMSampleBuffer!, _) in
                        
                        println("camera: captureStillImage")
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        let image = UIImage(data: imageData)
                        
                        println("camera: pickedImage")
                        self.pickedImage = image
                        
                        self.performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func selectImageButtonClicked(sender: UIBarButtonItem) {
        pickedImage = nil
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func moreButtonClicked(sender: UIButton) {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Settings", "Profile", "About")
        
        actionSheet.showInView(self.view)
    }
    
    @IBAction func backToMain(segue: UIStoryboardSegue) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        // Ask for Authorisation from the User.
//        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
//        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
//        }
        
        imagePicker.delegate = self
        
        // Setup Camera Preview
        
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        
        let devices = AVCaptureDevice.devices()
        println("AVCaptureDevice list")
        println(devices)
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.Back {
                    captureDevice = device as? AVCaptureDevice
                    
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromMainToSendingPicture" {
            if pickedImage != nil {
                let destination = segue.destinationViewController as! SendingPictureViewController
                destination.pickedImage = pickedImage
                pickedImage = nil
            }
            
            server.shouldSend = true
        } else if segue.identifier == "fromMainToPage" {
            let destination = segue.destinationViewController as! PageViewController
            destination.url = page_url
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            if device.lockForConfiguration(nil) {
                let autoFocusPoint = CGPointMake(0.5, 0.5)
                println(device.focusPointOfInterest)
                device.focusPointOfInterest = autoFocusPoint
                println(device.focusPointOfInterest)
                
                if device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
                    println("focus: ContinuousAutoFocus")
                    device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                } else if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                    println("focus: AutoFocus")
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                }
                
                device.unlockForConfiguration()
            }
            
            
//            let screenRect: CGRect = [[UIScreen mainScreen] bounds]
//            
//            let screenWidth = screenRect.size.width
//            let screenHeight = screenRect.size.height
//            let focus_x = thisFocusPoint.center.x/screenWidth
//            let focus_y = thisFocusPoint.center.y/screenHeight
//            
//            [[self captureManager].videoDevice lockForConfiguration:&error];
//            [[self captureManager].videoDevice setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
        }
    }
    
    func beginSession() {
        configureDevice()
        
        var err: NSError? = nil
        
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        stillImageOutput!.outputSettings = outputSettings
        
        if captureSession.canAddOutput(stillImageOutput) {
            println("camera:addOutput")
            
            captureSession.addOutput(stillImageOutput)
        } else {
            println("camera: couldn't add output")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
//        previewLayer?.frame = self.view.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureSession.startRunning()
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        pickedImage = image
        
        dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIActionSheetDelegate Methods
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            performSegueWithIdentifier("fromMainToSettings", sender: nil)
        case 3:
            page_url = "http://popart-app.com/static/about-us.html"
            performSegueWithIdentifier("fromMainToPage", sender: nil)
        default:
            println("actionSheet without action \(buttonIndex)")
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let placemark = placemarks[0] as! CLPlacemark
                
                self.locationManager.stopUpdatingLocation()
                
//                println(placemark.locality)
//                println(placemark.postalCode)
//                println(placemark.administrativeArea)
//                println(placemark.country)
                
                server.location = manager.location
                server.placemark = placemark
            } else {
                println("Problem with the data received from geocoder")
            }
        })
        
//        println("location (\(manager.location.coordinate.latitude), \(manager.location.coordinate.longitude))")
    }
    
}