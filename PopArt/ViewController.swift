//
//  ViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 14/08/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import SwiftHTTP

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var cameraView: UIView!
//    @IBOutlet weak var cameraButton: UIButton!
//    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var grid: UIImageView!
//    @IBOutlet var overlayView: OverlayView!
    @IBOutlet weak var overlayView: UIImageView!
    @IBOutlet weak var rectView: UIImageView!
    
//    var rectLayer: UIImageView!
    var rectArea: Float = -9990.0
    var rectDetectedAt: Double = -1
    
    let locationManager = CLLocationManager()
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage?
//    var croppedImage: UIImage?
    var keypoints: Array<Keypoint> = []
    var result: NSData?
    
    var page_url: String?
    
    var rects: [AnyObject] = []
    
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureDevice: AVCaptureDevice?
    var videoInput: AVCaptureInput?
    var videoOutput: AVCaptureVideoDataOutput?
    var isFront:Bool = false
    var waitingChange:Bool = false
    var maxZoomFactor:CGFloat = 10.0
    
    var stillImageOutput : AVCaptureStillImageOutput?
    
    var videoConnection : AVCaptureConnection?
    
    @IBOutlet weak var processImage: UIImageView!
    var shouldProcessImage : Bool = false
    var timer : NSTimer = NSTimer()
    
    var displayScanLine = false
    
    func changeProcessImage() {
        shouldProcessImage = !shouldProcessImage
        
    }
    
    func resetProcessImage() {
        self.waitingChange = false
        self.processImage.image = nil
        self.processImage.setNeedsDisplay()
    }
    
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
//        print(sender.scale)
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
                        
//                        print("Zoom: \(device.videoZoomFactor)")
                        
                        device.unlockForConfiguration()
                    } catch _ {
                        NSLog("could not lock")
                    }
                } else {
                    NSLog("No videoZoom feature")
                }
            } else {
                NSLog("No device")
            }
        }
    }
    
    @IBAction func cameraButtonClicked(sender: AnyObject) {
//        print("Camera")
        
        if captureDevice == nil {
            NSLog("fallback to library")
            
            //pickedImage = nil
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
            
            return
        } else {
            return
        }
        
        if let stillOutput = self.stillImageOutput {
            if stillOutput.capturingStillImage {
                NSLog("camera: capturing in progress")
            }
            
            // we do this on another thread so we don't hang the UI
            //let myQueue = dispatch_queue_create("My Queue", nil);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                //sleep(3)
                
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
                        
                        //let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        //let image = UIImage(data: imageData)
                        
                        //self.pickedImage = image
                        
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
//        print(slider.value)
        
        //var hardwareZoom = false
        
        if let device = captureDevice {
            if device.respondsToSelector("videoZoomFactor") {
                do {
                    try device.lockForConfiguration()
//                    print("Setting zoom")
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
        
        /*if !hardwareZoom {
            let frame = self.view.frame//captureDevice.frame
            let width = frame.size.width * slider.value
            let height = frame.size.height * slider.value
            let x = (frame.size.width - width)/2
            let y = (frame.size.height - height)/2
            
            captureDevice.bounds = CGRectMake(x, y, width, height)
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "changeProcessImage", userInfo: nil, repeats: true)
        
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
        
        //server.frameDetector?.topLeft = CGPoint(x: 100, y: 100)
        //server.frameDetector?.topRight = CGPoint(x: 200, y: 80)
        //server.frameDetector?.bottomLeft = CGPoint(x: 105, y: 260)
        //server.frameDetector?.bottomRight = CGPoint(x: 210, y: 275)
        
        // Create Focus Square
        
        server.squareSize = Int(self.view.bounds.width / 5)
        server.focusSquare = FocusSquareView(frame:CGRect(x: 0, y: 0, width: server.squareSize, height: server.squareSize))
        self.cameraView.addSubview(server.focusSquare!)
        server.focusSquare!.setNeedsDisplay()
        
        // Create Scan Line
        
        server.scanLine = ScanLineView(frame: CGRect(x: 0, y: 0, width: 2, height: self.view.bounds.height))
        self.cameraView.addSubview(server.scanLine!)
        server.scanLine!.setNeedsDisplay()
        
        // Setup Overlay and Rect views
        
        self.overlayView.alpha = 0.0
        self.rectView.alpha = 0.0
        
        // Setup Rectangle Layer
        
//        rectLayer = UIImageView(frame: self.cameraView.frame)
//        self.cameraView.addSubview(rectLayer)
        
        // Setup Camera Preview
        
        //captureSession.sessionPreset = AVCaptureSessionPresetHigh
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        NSLog("AVCaptureDevice list")
        print(devices)
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.Back {
                    captureDevice = device as? AVCaptureDevice
                    
                    if captureDevice != nil {
                        NSLog("Capture device found")
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
            //self.captureSession.stopRunning();
            
            if pickedImage != nil {
                let destination = segue.destinationViewController as! SendingPictureViewController
                destination.pickedImage = (self.processImage.image != nil) ? self.processImage.image : pickedImage
//                destination.croppedImage = (self.processImage.image != nil) ? self.processImage.image : croppedImage
                destination.keypoints = self.keypoints
                pickedImage = nil
//                croppedImage = nil
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
        } else if segue.identifier == "fromMainToResult" {
            if result != nil {
                let destination = segue.destinationViewController as! ResultViewController
                destination.result = result
                destination.saveToHistory = true
                result = nil
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
            NSLog("error: \(err?.localizedDescription)")
        }
        
        stillImageOutput = AVCaptureStillImageOutput()
        let outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        stillImageOutput!.outputSettings = outputSettings
        
        if captureSession.canAddOutput(stillImageOutput) {
            NSLog("camera:addOutput")
            
            captureSession.addOutput(stillImageOutput)
        } else {
            NSLog("camera: couldn't add output")
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        if videoOutput != nil {
            let sessionQueue = dispatch_queue_create("Camera Session", /*DISPATCH_QUEUE_SERIAL*/DISPATCH_QUEUE_CONCURRENT)
            
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
//        self.cameraView.bringSubviewToFront(rectLayer)
        self.cameraView.bringSubviewToFront(server.frameDetector!)
        self.cameraView.bringSubviewToFront(server.scanLine!)
        self.cameraView.bringSubviewToFront(server.focusSquare!)
        self.cameraView.bringSubviewToFront(grid)
        
        NSLog("ViewController#beginSession.cameraView.bounds: \(cameraView!.bounds)")
        NSLog("ViewController#beginSession.cameraView.frame: \(cameraView!.frame)")
        NSLog("ViewController#beginSession.previewLayer.bounds: \(previewLayer!.bounds)")
        NSLog("ViewController#beginSession.previewLayer.frame: \(previewLayer!.frame)")
        
        captureSession.startRunning()
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if server.sendingPicture {
            dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            return
        }
        
        pickedImage = image
        
        let stitchedImage:stringedImage? = CVWrapper.processImageWithOpenCV(pickedImage) as stringedImage
        self.keypoints = []
        
        var gotKeypoints = false
        
        if let result = stitchedImage {
//            pickedImage = result.overlayImageWithImage
//            croppedImage = pickedImage
            
            if let keys = result.keypoints {
                for k in keys {
                    let keypoint = Keypoint()
                    keypoint.angle = k.angle
                    keypoint.class_id = k.class_id
                    keypoint.octave = k.octave
                    keypoint.pt = k.pt
                    keypoint.response = k.response
                    keypoint.size = k.size
                    keypoint.descriptor = k.descriptor
                    keypoints.append(keypoint)
                }
                
                gotKeypoints = true
                
                dismissViewControllerAnimated(true, completion: {
//                    self.performSegueWithIdentifier("fromMainToSendingPicture", sender: nil)
                    
                    self.reloadOverVew(result.overlayImageWithImage)
                    
                    server.shouldSend = true
                    self.sendPictureToServer(self.pickedImage)
                })
                UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            }
        }
        
        if !gotKeypoints {
            dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        }
//        }
        
//        for var i = 0; i < 100; i++ {
//            let (detectedImage, croppedImage, detectMessage, top_left, top_right, bottom_left, bottom_right) = server.frameDetector!.detectUsingCIDetector(pickedImage!)
//            
//            if detectedImage == nil {
//                print("fallback to GPUImage's HarrisCorner method")
//            } else {
//                pickedImage = detectedImage
//                self.croppedImage = croppedImage
//                
//                if detectMessage != nil {
//                }
//            }
//        }
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
        
//        let rectlayers = previewLayer?.sublayers
//        if rectlayers?.count > 0{
//            previewLayer?.sublayers = nil
//        }
//
        if server.sendingPicture {
            return
        }
        
//        if (!shouldProcessImage) {
//            return;
//        }else {
//            shouldProcessImage = false;
//        }
        
        let bufferImage = imageFromSampleBuffer(sampleBuffer)
//        let resizedBufferImage = FrameDetectorView.scaleUIImageToSize(bufferImage, size: overlayView.frame.size)
        
        self.pickedImage = bufferImage
//        self.croppedImage = resizedBufferImage
        
//        NSLog("ViewController#captureOutput.cameraView.frame: \(cameraView.frame)")
//        NSLog("ViewController#captureOutput.cameraView.bounds: \(cameraView.bounds)")
//        NSLog("ViewController#captureOutput.overlayView.frame: \(overlayView.frame)")
//        NSLog("ViewController#captureOutput.overlayView.bounds: \(overlayView.bounds)")
        
        //self.performSelector(Selector("resetProcessImage"), withObject: nil, afterDelay: 2.0)
//        self.pickedImage = bufferImage
//        self.croppedImage = bufferImage
//return
//        let dataImg:NSdata=UIImageJPEGRepresentation(imagen,1.0)
        let my_queue = dispatch_queue_create("myq", nil)
        dispatch_async(my_queue) {
            
            let pros : stringedImage = CVWrapper.processImageWithOpenCV(self.pickedImage) as stringedImage
            
            dispatch_async(dispatch_get_main_queue(),{
                self.rectView.image = pros.overlayImageWithImage
                self.rectView.contentMode = .ScaleAspectFill
                self.rectView.alpha = 1.0
            })
            
            self.keypoints = []
            
            if let keys = pros.keypoints {
                let tmpRectArea = pros.rectArea.floatValue
                let currentTime = NSDate().timeIntervalSince1970*1000
                
                NSLog("TmpRectArea: \(tmpRectArea)")
                NSLog("RectArea: \(self.rectArea)")
                
                if abs(self.rectArea - tmpRectArea) > 10000 {
                    self.rectDetectedAt = currentTime
                    NSLog("RectDetectedAt: \(self.rectDetectedAt)")
                }
                self.rectArea = tmpRectArea
                
                for k in keys {
                    let keypoint = Keypoint()
                    keypoint.angle = k.angle
                    keypoint.class_id = k.class_id
                    keypoint.octave = k.octave
                    keypoint.pt = k.pt
                    keypoint.response = k.response
                    keypoint.size = k.size
                    keypoint.descriptor = k.descriptor
                    self.keypoints.append(keypoint)
                }

                if currentTime - self.rectDetectedAt >= 2000 {
                    NSLog("CurrentTime: \(currentTime)")
                    NSLog("DetectedAt: \(self.rectDetectedAt)")
                    NSLog("Upload!")
                    
                    self.reloadOverVew(pros.overlayImageWithImage)
                    
                    server.shouldSend = true
                    self.sendPictureToServer(self.pickedImage)
                    return
                } else {
                    NSLog("Wait: \(currentTime - self.rectDetectedAt)")
                }
            }
            
//            self.croppedImage = pros.cropedImage;
//            self.pickedImage = pros.cropedImage;
            
            //self.processImage.image = self.pickedImage
            //self.processImage.setNeedsDisplay()
            
//            if (pros.str.isEmpty){
//                //if (!self.waitingChange){
//                    self.waitingChange = true;
//                
//                    self.resetProcessImage()
//                //}
//            }else {
//                //if (!self.waitingChange){
//                    self.waitingChange = true;
//                self.processImage.image = nil;//pros.image;
//                    self.processImage.setNeedsDisplay()
//                
//                    self.performSelector(Selector("resetProcessImage"), withObject: nil, afterDelay: 1.0)
//                //}
//            }
//            dispatch_async(dispatch_get_main_queue(),{
//////                self.reloadOverVew(FrameDetectorView.scaleUIImageToSize(pros.overlayImage, size: self.overlayView.frame.size))
////                let resizedImage = FrameDetectorView.scaleUIImageToSize(pros.overlayImageWithImage, size: self.overlayView.frame.size)
////                self.reloadOverVew(resizedImage)
//            })
            
            //self.resetProcessImage()
            //let stitchedImage:UIImage = CVWrapper.processImageWithOpenCV(self.pickedImage) as UIImage
            //sleep(2)
//            NSLog("ViewController: %@", stitchedImage)
            
            //self.pickedImage = stitchedImage
            //self.croppedImage = self.pickedImage
            //self.processImage.image = self.pickedImage
            //self.processImage.setNeedsDisplay()
            //self.performSelector(Selector("resetProcessImage"), withObject: nil, afterDelay: 0.5)
            
            //self.resetProcessImage()
            
//            let (detectedImage, croppedImage, detectMessage, top_left, top_right, bottom_left, bottom_right) = server.frameDetector!.detectUsingCIDetector(resizedBufferImage)
//            self.previewLayer?.setNeedsDisplay()
//            if detectedImage == nil {
//                //            print("fallback to GPUImage's HarrisCorner method")
//                NSLog("Not Detected")
//                
//                server.frameDetector?.topLeft = nil
//                server.frameDetector?.topRight = nil
//                server.frameDetector?.bottomLeft = nil
//                server.frameDetector?.bottomRight = nil
//                
//                server.frameDetector!.setNeedsDisplay()
//            } else {
//                //            pickedImage = detectedImage
//                self.croppedImage = croppedImage
//                
//                server.frameDetector?.topLeft = CGPoint(x: top_left!.x/2, y: top_left!.y/2)
//                server.frameDetector?.topRight = CGPoint(x: top_right!.x/2, y: top_right!.y/2)
//                server.frameDetector?.bottomLeft = CGPoint(x: bottom_left!.x/2, y: bottom_left!.y/2)
//                server.frameDetector?.bottomRight = CGPoint(x: bottom_right!.x/2, y: bottom_right!.y/2)
//                server.frameDetector?.imagesize = detectedImage?.size
//                server.frameDetector!.setNeedsDisplay()
//                
//                NSLog("Detected")
//                //            print(top_left)
//                //            print(bottom_right)
//                
//                if detectMessage != nil {
//                }
//            }
            
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
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let bitsPerComponent: Int = 8
        let newContext = CGBitmapContextCreate(baseAddress, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
//        CGImageAlphaInfo.NoneSkipFirst.rawValue
        
        let imageRef: CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return resultImage
    }

    func reloadOverVew(image:UIImage?) {
//        self.overlayView.rects = rects
//        self.overlayView.keypoints = keys
        self.overlayView.image = image
        self.overlayView.contentMode = .ScaleAspectFill
//        self.overlayView.backgroundColor = UIColor.redColor()
        self.overlayView.alpha = 1.0
//        self.overlayView.setNeedsDisplay()
        
        NSLog("ViewController#reloadOverVew.overlayView.overlayImage.frame: \(self.overlayView.frame)")
        if image != nil {
            NSLog("ViewController#reloadOverVew.image.size: \(image!.size)")
        }
    }
    
    func sendPictureToServer(imageToSend: UIImage?) {
        if !server.shouldSend { return }
        if server.sendingPicture { return }
        
        let currentTime = NSDate().timeIntervalSince1970*1000
        NSLog("Start Upload At: \(currentTime)")
        
        server.shouldSend = false
        server.sendingPicture = true
        
        server.scanLine!.startAnimation(self.view.bounds.width)
        
        // Get location
        
        if server.location != nil {
            print("User location: (\(server.location!.coordinate.latitude), \(server.location!.coordinate.longitude))")
        } else {
            print("User didnt allow location")
        }
        
        // Send to server
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if imageToSend != nil {
                let imageData = UIImageJPEGRepresentation(imageToSend!, 0.2)
                
                var messageKeypoints:Array<Dictionary<String, AnyObject>> = []
                for k in self.keypoints {
                    let json_keypoint: Dictionary<String, AnyObject> = [
                        "a": k.angle,
                        "c": NSNumber(int: k.class_id),
                        "o": NSNumber(int: k.octave),
                        "px": k.pt.x,
                        "py": k.pt.y,
                        "r": k.response,
                        "s": k.size,
                        "d": k.descriptor
                    ]
                    
                    messageKeypoints.append(json_keypoint);
                }
                
                var messageKeypointsJson: AnyObject = ""
                do {
                    messageKeypointsJson = try NSJSONSerialization.dataWithJSONObject(messageKeypoints, options: NSJSONWritingOptions.init(rawValue: 0))
                } catch _ {}
                
                var message_lat = ""
                var message_lng = ""
                var message_location_area = ""
                var message_location_country = ""
                
                if server.location != nil {
                    message_lat = String(stringInterpolationSegment: server.location!.coordinate.latitude)
                    message_lng = String(stringInterpolationSegment: server.location!.coordinate.longitude)
                }
                
                if server.placemark != nil {
                    if let thoroughfare = server.placemark!.thoroughfare {
                        message_location_area += "\(thoroughfare), "
                    }
                    if let subThoroughfare = server.placemark!.subThoroughfare {
                        message_location_area += "\(subThoroughfare), "
                    }
                    if let postalCode = server.placemark!.postalCode {
                        message_location_area += "\(postalCode)"
                    }
                    
                    if let locality = server.placemark!.locality {
                        message_location_country += "\(locality), "
                    }
                    if let administrativeArea = server.placemark!.administrativeArea {
                        message_location_country += "\(administrativeArea), "
                    }
                    if let country = server.placemark!.country {
                        message_location_country += "\(country)"
                    }
                }
                
                var uid = ""
                var token = ""
                var client = ""
                
                if let account = Account.load() {
                    uid = account.uid
                    token = account.token
                    client = account.client
                }
                
                let params: Dictionary<String, AnyObject> = ["image": Upload(data: imageData!, fileName: "upload.jpg", mimeType: "image/jpeg"), "lat": message_lat, "lng": message_lng, "location_area": message_location_area, "location_country": message_location_country, "uid": uid, "token": token, "client": client, "keypoints": NSString(data: messageKeypointsJson as! NSData, encoding: NSUTF8StringEncoding)!]
                
                server.ping(self)
                
                do {
                    let opt = try HTTP.POST(server.http_url, parameters: params)
                    
                    opt.start { response in
                        if let err = response.error {
                            print("error: \(err.localizedDescription)")
                            
                            let finishTime = NSDate().timeIntervalSince1970*1000
                            NSLog("Finish Upload At: \(finishTime)")
                            NSLog("Time Difference: \(finishTime - currentTime)")
                            
                            server.scanLine!.stopAnimation()
                            server.sendingPicture = false
                            self.overlayView.alpha = 0.0
                            return //also notify app of failure as needed
                        }
                        
                        let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                        print("response: \(str)") //prints the HTML of the page
                        
                        self.result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                        
                        let finishTime = NSDate().timeIntervalSince1970*1000
                        NSLog("Finish Upload At: \(finishTime)")
                        NSLog("Time Difference: \(finishTime - currentTime)")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            server.scanLine!.stopAnimation()
                            server.sendingPicture = false
                            self.overlayView.alpha = 0.0
                            self.performSegueWithIdentifier("fromMainToResult", sender: nil)
                        }
                    }
                } catch let error {
                    server.scanLine!.stopAnimation()
                    server.sendingPicture = false
                    self.overlayView.alpha = 0.0
                    print("got an error creating the request: \(error)")
                }
            } else {
                server.scanLine!.stopAnimation()
                server.sendingPicture = false
                self.overlayView.alpha = 0.0
            }
        }
    }
    
    func compressImage(image: UIImage) -> UIImage {
        var actualHeight = Double(image.size.height)
        var actualWidth = Double(image.size.width)
        let maxHeight = 600.0
        let maxWidth = 800.0
        var imgRatio = actualWidth/actualHeight
        let maxRatio = maxWidth/maxHeight
        let compressionQuality = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(Int(actualWidth)), CGFloat(Int(actualHeight)))
        UIGraphicsBeginImageContext(rect.size)
        
        image.drawInRect(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData!)!
    }
    
}
