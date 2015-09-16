//
//  ViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 14/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
//    @IBOutlet weak var cameraButton: UIButton!
//    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    
    let locationManager = CLLocationManager()
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
    
    var page_url: String?
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var videoInput:AVCaptureInput?
    var isFront:Bool = false
    
    var stillImageOutput : AVCaptureStillImageOutput?
    
    var videoConnection : AVCaptureConnection?
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        println("Camera")
        
        if captureDevice == nil {
//            performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
            println("fallback to library")
            
            pickedImage = nil
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
            
            return
        }
        
        if let stillOutput = self.stillImageOutput {
            if stillOutput.capturingStillImage {
                println("camera: capturing in progress")
            }
            
            // we do this on another thread so we don't hang the UI
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // find video connection
                for connection in stillOutput.connections {
                    // find a matching input port
                    for port in connection.inputPorts! {
                        // and matching type
                        if port.mediaType == AVMediaTypeVideo {
                            self.videoConnection = connection as? AVCaptureConnection
                            break
                        }
                    }
                    if self.videoConnection != nil {
                        break // for connection
                    }
                }
                
                switch (UIApplication.sharedApplication().statusBarOrientation)
                {
                case UIInterfaceOrientation.Portrait:
                    self.videoConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                case UIInterfaceOrientation.PortraitUpsideDown:
                    self.videoConnection?.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
                case UIInterfaceOrientation.LandscapeLeft:
                    self.videoConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                case UIInterfaceOrientation.LandscapeRight:
                    self.videoConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                default:
                    self.videoConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                }
                
                if self.videoConnection != nil {
                    // found the video connection, let's get the image
                    stillOutput.captureStillImageAsynchronouslyFromConnection(self.videoConnection) {
                        (imageSampleBuffer:CMSampleBuffer!, _) in
                        
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        let image = UIImage(data: imageData)
                        
                        self.pickedImage = image
                        
                        self.performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func onRotateCamera(sender: AnyObject) {
        if isFront {
            captureDevice = getBackCamera()
            isFront = false
        } else {
            captureDevice = getFrontCamera()
            isFront = true
        }
        
        if captureDevice != nil {
            println("Capture device found")
            beginSession()
        }
    }
    
    func getFrontCamera () -> AVCaptureDevice! {
        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            var camera:AVCaptureDevice = device as! AVCaptureDevice
            if camera.position == AVCaptureDevicePosition.Front {
                return camera
            }
        }
        return nil
    }
    
    func getBackCamera () -> AVCaptureDevice! {
        var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            var camera:AVCaptureDevice = device as! AVCaptureDevice
            if camera.position == AVCaptureDevicePosition.Back {
                return camera
            }
        }
        return nil
    }
    
//    @IBAction func selectImageButtonClicked(sender: UIBarButtonItem) {
//        pickedImage = nil
//        
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .PhotoLibrary
//        
//        presentViewController(imagePicker, animated: true, completion: nil)
//    }
    
//    @IBAction func moreButtonClicked(sender: UIButton) {
//        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Settings", "Profile", "About")
//        
//        actionSheet.showInView(self.view)
//    }
    
    @IBAction func backToMain(segue: UIStoryboardSegue) {}

    @IBAction func sliderValueChanged(sender: AnyObject) {
        println(slider.value)
        
        var hardwareZoom = false
        
        if let device = captureDevice {
            if device.respondsToSelector("videoZoomFactor") {
                if device.lockForConfiguration(nil) {
                    println("Setting zoom")
                    device.videoZoomFactor = CGFloat(slider.value)

                    device.unlockForConfiguration()
                    hardwareZoom = true
                } else {
                    println("could not lock")
                }
            } else {
                println("No videoZoom feature")
            }
        } else {
            println("No device")
        }
        
        if !hardwareZoom {
//            let frame = captureDevice.frame
//            let width = frame.size.width * slider.value
//            let height = frame.size.height * slider.value
//            let x = (frame.size.width - width)/2
//            let y = (frame.size.height - height)/2
//            
//            captureDevice.bounds = CGRectMake(x, y, width, height)
        }
    }
    
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
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
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
                    isFront = false
                }
            }
        }
        
//        for fontFamilyName in UIFont.familyNames() {
//            println("-- \(fontFamilyName) --")
//            
//            for fontName in UIFont.fontNamesForFamilyName(fontFamilyName as! String) {
//                println(fontName)
//            }
//            
//            println(" ")
//        }
//        label1.font = UIFont(name: "YanoneKaffeesatz-Regular", size: 20.0)
//        label1.text = "Tips and Tricks in Xcode"
//        
//        label2.font = UIFont(name: "YanoneKaffeesatz-Bold", size: 20.0)
//        label2.text = "Tips and Tricks in Xcode"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if previewLayer != nil {
            let bounds = cameraView.layer.bounds
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer?.bounds = bounds
            previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
            
            let connection = previewLayer?.connection
            
            switch (UIApplication.sharedApplication().statusBarOrientation)
            {
            case UIInterfaceOrientation.Portrait:
                connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            case UIInterfaceOrientation.PortraitUpsideDown:
                connection?.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            case UIInterfaceOrientation.LandscapeLeft:
                connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            case UIInterfaceOrientation.LandscapeRight:
                connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            default:
                connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            }
        }
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
        } else if segue.identifier == "fromMainToMenu" {
            if let controller = segue.destinationViewController as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController!.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
                controller.preferredContentSize = CGSize(width: self.view.frame.width-20, height: 140)
            }
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            if device.lockForConfiguration(nil) {
//                let autoFocusPoint = CGPointMake(0.5, 0.5)
//                device.focusPointOfInterest = autoFocusPoint
                
                if device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) {
                    println("focus: ContinuousAutoFocus")
                    device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                } else if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                    println("focus: AutoFocus")
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                }
                
                if device.respondsToSelector("setVideoZoomFactor:") {
                    slider.maximumValue = min(Float(device.activeFormat.videoMaxZoomFactor), 20.0)
                }
                
                device.unlockForConfiguration()
            }
        }
    }
    
    func beginSession() {
        configureDevice()
        
        var err: NSError? = nil
        if videoInput != nil {
            captureSession.stopRunning()
            
            captureSession.removeInput(videoInput)
            videoInput = AVCaptureDeviceInput(device: captureDevice, error: &err)
            captureSession.addInput(videoInput)
            captureSession.startRunning()
            return
        }
        videoInput = AVCaptureDeviceInput(device: captureDevice, error: &err)
        captureSession.addInput(videoInput)
        
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
        self.cameraView.layer.addSublayer(previewLayer)
        
        self.cameraView.bringSubviewToFront(slider)
        
        captureSession.startRunning()
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        pickedImage = image
        
        dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
        })
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
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
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
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