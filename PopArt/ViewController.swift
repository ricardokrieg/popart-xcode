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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var cameraView: UIView!
//    @IBOutlet weak var cameraButton: UIButton!
//    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var grid: UIImageView!
    
    let locationManager = CLLocationManager()
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
    var croppedImage: UIImage?
    
    var page_url: String?
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var videoInput: AVCaptureInput?
    var videoOutput: AVCaptureVideoDataOutput?
    var isFront:Bool = false
    var maxZoomFactor:CGFloat = 10.0
    
    var stillImageOutput : AVCaptureStillImageOutput?
    
    var videoConnection : AVCaptureConnection?
    
    @IBAction func handleTouch(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if let view = sender.view {
                if let focusSquare = server.focusSquare {
                    let point = sender.locationInView(sender.view)
                    
                    // checking if touch is inside current square (hide it if positive)
                    if CGRectContainsPoint(focusSquare.frame, point) {
                        focusSquare.layer.removeAllAnimations()
                        focusSquare.center.x = 0
                        focusSquare.center.y = 0
                        focusSquare.alpha = 0.0
                    } else {
                        let screenBounds = view.bounds
                        let autoFocusPoint = CGPointMake(point.x/screenBounds.size.width, point.y/screenBounds.size.height)
                
                        focusSquare.center.x = point.x
                        focusSquare.center.y = point.y
                
                        focusSquare.setNeedsDisplay()
                
                        focusSquare.alpha = 0.1
                        UIView.animateWithDuration(1.0, delay: 0.0, options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
                                focusSquare.alpha = 1.0
                            }, completion: nil)
                
                        if let device = captureDevice {
                            do {
                                try device.lockForConfiguration()
                                if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
                                    device.focusMode = AVCaptureFocusMode.AutoFocus
                                }
                                if device.focusPointOfInterestSupported {
                                    device.focusPointOfInterest = autoFocusPoint
                                }
                        
                                if device.isExposureModeSupported(AVCaptureExposureMode.AutoExpose) {
                                    device.exposureMode = AVCaptureExposureMode.AutoExpose
                                }
                                if device.exposurePointOfInterestSupported {
                                    device.exposurePointOfInterest = autoFocusPoint
                                }
                        
                                device.unlockForConfiguration()
                            } catch _ {
                            }
                        } else {
                            print("No device")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func handlePinch(sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        if let _ = sender.view {
            if let device = captureDevice {
                if device.respondsToSelector("videoZoomFactor") {
                    do {
                        try device.lockForConfiguration()
                        var tempZoomFactor = device.videoZoomFactor
                        
                        tempZoomFactor = CGFloat(tempZoomFactor * sender.scale)
                        tempZoomFactor = CGFloat(min(tempZoomFactor, maxZoomFactor))
                        tempZoomFactor = CGFloat(max(tempZoomFactor, 1.0))
                        
                        device.videoZoomFactor = tempZoomFactor
                        sender.scale = 1
                        
                        print("Zoom: \(device.videoZoomFactor)")
                        
                        device.unlockForConfiguration()
                    } catch _ {
                        print("could not lock")
                    }
                } else {
                    print("No videoZoom feature")
                }
            } else {
                print("No device")
            }
        }
    }
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
        print("Camera")
        
        if captureDevice == nil {
            print("fallback to library")
            
            pickedImage = nil
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
            
            return
        }
        
        if let stillOutput = self.stillImageOutput {
            if stillOutput.capturingStillImage {
                print("camera: capturing in progress")
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
                        
//                        self.pickedImage = image
                        
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
            print("Capture device found")
            beginSession()
        }
    }
    
    func getFrontCamera () -> AVCaptureDevice! {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            let camera:AVCaptureDevice = device as! AVCaptureDevice
            if camera.position == AVCaptureDevicePosition.Front {
                return camera
            }
        }
        return nil
    }
    
    func getBackCamera () -> AVCaptureDevice! {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            let camera:AVCaptureDevice = device as! AVCaptureDevice
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
        print(slider.value)
        
//        var hardwareZoom = false
        
        if let device = captureDevice {
            if device.respondsToSelector("videoZoomFactor") {
                do {
                    try device.lockForConfiguration()
                    print("Setting zoom")
                    device.videoZoomFactor = CGFloat(slider.value)

                    device.unlockForConfiguration()
//                    hardwareZoom = true
                } catch _ {
                    print("could not lock")
                }
            } else {
                print("No videoZoom feature")
            }
        } else {
            print("No device")
        }
        
//        if !hardwareZoom {
//            let frame = captureDevice.frame
//            let width = frame.size.width * slider.value
//            let height = frame.size.height * slider.value
//            let x = (frame.size.width - width)/2
//            let y = (frame.size.height - height)/2
//            
//            captureDevice.bounds = CGRectMake(x, y, width, height)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        server.authenticateUser("ViewController", checkToken: server.shouldCheckToken)
        server.shouldCheckToken = true
        
        server.ping(self)

        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        imagePicker.delegate = self
        
        // Create Frame Detector View
        
        server.frameDetector = FrameDetectorView(frame: self.view.bounds)
        server.frameDetector!.backgroundColor = UIColor.clearColor()
        self.cameraView.addSubview(server.frameDetector!)
        server.frameDetector!.setNeedsDisplay()
        
//        server.frameDetector?.topLeft = CGPoint(x: 100, y: 100)
//        server.frameDetector?.topRight = CGPoint(x: 200, y: 80)
//        server.frameDetector?.bottomLeft = CGPoint(x: 105, y: 260)
//        server.frameDetector?.bottomRight = CGPoint(x: 210, y: 275)
        
        // Create Focus Square
        
        server.squareSize = Int(self.view.bounds.width / 5)
        server.focusSquare = FocusSquareView(frame:CGRect(x: 0, y: 0, width: server.squareSize, height: server.squareSize))
        self.cameraView.addSubview(server.focusSquare!)
        server.focusSquare!.setNeedsDisplay()
        
        // Setup Camera Preview
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        print("AVCaptureDevice list")
        print(devices)
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.Back {
                    captureDevice = device as? AVCaptureDevice
                    
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                    isFront = false
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                destination.croppedImage = croppedImage
                pickedImage = nil
                croppedImage = nil
            }
            
            server.shouldSend = true
        } else if segue.identifier == "fromMainToPage" {
            let destination = segue.destinationViewController as! PageViewController
            destination.url = page_url
        } else if segue.identifier == "fromMainToMenu" {
            if let controller = segue.destinationViewController as UIViewController? {
                controller.popoverPresentationController!.delegate = self
                controller.popoverPresentationController!.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
                let width = min(self.view.frame.width-20, 320)
                controller.preferredContentSize = CGSize(width: width, height: 140)
            }
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                
                if device.respondsToSelector("setVideoZoomFactor:") {
                    slider.maximumValue = min(Float(device.activeFormat.videoMaxZoomFactor), 10.0)
                    maxZoomFactor = CGFloat(min(Float(device.activeFormat.videoMaxZoomFactor), 10.0))
                }
                
                device.unlockForConfiguration()
            } catch _ {
            }
        }
    }
    
    func beginSession() {
        configureDevice()
        
        var err: NSError? = nil
        if videoInput != nil {
            captureSession.stopRunning()
            
            captureSession.removeInput(videoInput)
            do {
                videoInput = try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                err = error
                videoInput = nil
            }
            captureSession.addInput(videoInput)
            captureSession.startRunning()
            return
        }
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            videoInput = nil
        }
        captureSession.addInput(videoInput)
        
        if err != nil {
            print("error: \(err?.localizedDescription)")
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        stillImageOutput!.outputSettings = outputSettings
        
        if captureSession.canAddOutput(stillImageOutput) {
            print("camera:addOutput")
            
            captureSession.addOutput(stillImageOutput)
        } else {
            print("camera: couldn't add output")
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        if videoOutput != nil {
            let sessionQueue = dispatch_queue_create("Camera Session", DISPATCH_QUEUE_SERIAL)
            
            dispatch_async(sessionQueue, {
//                kCVPixelFormatType_32ARGB
//                self.videoOutput!.videoSettings = NSDictionary(object: Int(kCVPixelFormatType_32BGRA), forKey:kCVPixelBufferPixelFormatTypeKey)
                self.videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
                self.videoOutput!.alwaysDiscardsLateVideoFrames = true
                self.videoOutput!.setSampleBufferDelegate(self, queue: sessionQueue)
                
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(self.videoOutput)
                }
            })
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraView.layer.addSublayer(previewLayer!)
        
        self.cameraView.bringSubviewToFront(slider)
        self.cameraView.bringSubviewToFront(server.frameDetector!)
        self.cameraView.bringSubviewToFront(server.focusSquare!)
        self.cameraView.bringSubviewToFront(grid)
        
        print("CameraView (bounds): \(cameraView!.bounds)")
        print("CameraViewr (frame): \(cameraView!.frame)")
        print("PreviewLayer (bounds): \(previewLayer!.bounds)")
        print("PreviewLayer (frame): \(previewLayer!.frame)")
        
        captureSession.startRunning()
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        pickedImage = image
        
        let (detectedImage, croppedImage, detectMessage, top_left, top_right, bottom_left, bottom_right) = FrameDetectorView.detectUsingCIDetector(pickedImage!)
        
        if detectedImage == nil {
            print("fallback to GPUImage's HarrisCorner method")
        } else {
            pickedImage = detectedImage
            self.croppedImage = croppedImage
            
            if detectMessage != nil {
            }
        }
        
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
            print("actionSheet without action \(buttonIndex)")
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0] as CLPlacemark
                
                self.locationManager.stopUpdatingLocation()
                
                server.location = manager.location
                server.placemark = placemark
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Methods
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        let bufferImage = imageFromSampleBuffer(sampleBuffer)
        let resizedBufferImage = FrameDetectorView.scaleUIImageToSize(bufferImage, size: cameraView.frame.size)
        
        self.pickedImage = resizedBufferImage
        self.croppedImage = resizedBufferImage

//        let dataImg:NSdata=UIImageJPEGRepresentation(imagen,1.0)
        
        let (detectedImage, croppedImage, detectMessage, top_left, top_right, bottom_left, bottom_right) = FrameDetectorView.detectUsingCIDetector(resizedBufferImage)
        
        if detectedImage == nil {
//            print("fallback to GPUImage's HarrisCorner method")
            NSLog("Not Detected")
            
            server.frameDetector?.topLeft = nil
            server.frameDetector?.topRight = nil
            server.frameDetector?.bottomLeft = nil
            server.frameDetector?.bottomRight = nil
            
            server.frameDetector!.setNeedsDisplay()
        } else {
//            pickedImage = detectedImage
            self.croppedImage = croppedImage
            
            server.frameDetector?.topLeft = CGPoint(x: top_left!.x/2, y: top_left!.y/2)
            server.frameDetector?.topRight = CGPoint(x: top_right!.x/2, y: top_right!.y/2)
            server.frameDetector?.bottomLeft = CGPoint(x: bottom_left!.x/2, y: bottom_left!.y/2)
            server.frameDetector?.bottomRight = CGPoint(x: bottom_right!.x/2, y: bottom_right!.y/2)
            
            server.frameDetector!.setNeedsDisplay()
            
            NSLog("Detected")
//            print(top_left)
//            print(bottom_right)
            
            if detectMessage != nil {
            }
        }
    }
    
    func imageFromSampleBuffer(sampleBuffer :CMSampleBufferRef) -> UIImage {
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let baseAddress: UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, Int(0))
        
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitsPerComponent: Int = 8
        let newContext = CGBitmapContextCreate(baseAddress, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGImageAlphaInfo.NoneSkipFirst.rawValue)
        
        let imageRef: CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return resultImage
    }
    
}
