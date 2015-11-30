//
//  SendingPictureViewController.swift
//  PopsArt
//
//  Created by Netronian Inc. on 22/08/15.
//  Copyright © 2015 PopsArt. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftHTTP
import GPUImage
import CoreImage

class SendingPictureViewController: UIViewController {
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var gpuImageContainer: GPUImageView!
    
    var pickedImage: UIImage?
    var result: NSData?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if !server.shouldSend { return }
        
        self.statusLabel.text = "Searching"
        
        // Display capture/picked image
        
        if pickedImage != nil {
            let (detectedImage, croppedImage) = detectUsingCIDetector(pickedImage!, imageContainer: imageContainer)
            
            if detectedImage == nil {
                print("fallback to GPUImage's HarrisCorner method")
                gpuImageContainer.hidden = true
            } else {
                pickedImage = detectedImage
                gpuImageContainer.hidden = true
            }
            
            imageContainer.contentMode = .ScaleAspectFit
            imageContainer.image = compressImage(pickedImage!)
            
            // TODO testing GPUImage - start
//            print("GPUImage - Start")
            
//            let sobel = GPUImageSobelEdgeDetectionFilter()
//            sobel.edgeStrength = 0.25
//            sobel.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
//            gpu_image.addTarget(sobel)
//            sobel.addTarget(gpuImageContainer)
//            gpu_image?.processImage()
            
//            pickedImage = gpu_image.imageFromCurrentFramebuffer()
            
            
            
            
//            gpuImageContainer.contentMode = .ScaleAspectFit
////            let gpu_image = GPUImagePicture(image: compressImage(pickedImage!))
////            gpu_image.addTarget(gpuImageContainer)
////            gpu_image?.processImage()
//            
//            let gpu_image = GPUImagePicture(image: pickedImage!)
//            
//            let sobel = GPUImageSobelEdgeDetectionFilter()
//            sobel.edgeStrength = 0.75
//            sobel.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
////            gpu_image.addTarget(sobel)
////            sobel.addTarget(gpuImageContainer)
//            
////            let filter = GPUImageHoughTransformLineDetector()
////            filter.lineDetectionThreshold = 0.40
////            
////            let lineGenerator = GPUImageLineGenerator()
////            
////            lineGenerator.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
////            lineGenerator.setLineColorRed(0.0, green:1.0, blue:0.0)
////            
////            filter.linesDetectedBlock = { (lineArray:UnsafeMutablePointer<GLfloat>, linesDetected:UInt, frameTime:CMTime) in
////                lineGenerator.renderLinesFromArray(lineArray, count:linesDetected, frameTime:frameTime)
////            }
////            
////            gpu_image.addTarget(sobel)
////            sobel.addTarget(filter)
//////            gpu_image.addTarget(filter)
////            
////            let blendFilter = GPUImageAlphaBlendFilter()
////            blendFilter.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
////            let gammaFilter = GPUImageGammaFilter()
////            gpu_image.addTarget(gammaFilter)
////            gammaFilter.addTarget(blendFilter)
////            
////            lineGenerator.addTarget(blendFilter)
////            
////            blendFilter.addTarget(gpuImageContainer)
//            
//            let filter = GPUImageHarrisCornerDetectionFilter()
//            filter.threshold = 0.20
//            filter.sensitivity = 5.0
//            
//            let crosshairGenerator = GPUImageCrosshairGenerator()
//            crosshairGenerator.crosshairWidth = 15.0
//            crosshairGenerator.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
//            
//            filter.cornersDetectedBlock = { (cornerArray:UnsafeMutablePointer<GLfloat>, cornersDetected:UInt, frameTime:CMTime) in
//                crosshairGenerator.renderCrosshairsFromArray(cornerArray, count:cornersDetected, frameTime:frameTime)
//            }
//
////            gpu_image.addTarget(filter)
//            gpu_image.addTarget(sobel)
//            sobel.addTarget(filter)
//            
//            let blendFilter = GPUImageAlphaBlendFilter()
//            blendFilter.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
//            let gammaFilter = GPUImageGammaFilter()
////            filter.addTarget(gammaFilter)
//            gpu_image.addTarget(gammaFilter)
//            gammaFilter.addTarget(blendFilter)
//            
//            crosshairGenerator.addTarget(blendFilter)
//            
//            blendFilter.addTarget(gpuImageContainer)
//            
////            let filter = GPUImageNobleCornerDetectionFilter()
////            filter.threshold = 0.20
////            filter.sensitivity = 5.0
////            
////            let crosshairGenerator = GPUImageCrosshairGenerator()
////            crosshairGenerator.crosshairWidth = 15.0
////            crosshairGenerator.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
////            
////            filter.cornersDetectedBlock = { (cornerArray:UnsafeMutablePointer<GLfloat>, cornersDetected:UInt, frameTime:CMTime) in
////                crosshairGenerator.renderCrosshairsFromArray(cornerArray, count:cornersDetected, frameTime:frameTime)
////            }
////            
//////            gpu_image.addTarget(filter)
////            gpu_image.addTarget(sobel)
////            sobel.addTarget(filter)
////            
////            let blendFilter = GPUImageAlphaBlendFilter()
////            blendFilter.forceProcessingAtSize(gpuImageContainer.sizeInPixels)
////            let gammaFilter = GPUImageGammaFilter()
////            gpu_image.addTarget(gammaFilter)
////            gammaFilter.addTarget(blendFilter)
////            
////            crosshairGenerator.addTarget(blendFilter)
////            
////            blendFilter.addTarget(gpuImageContainer)
//            
//            gpu_image?.processImage()
//            print("GPUImage - End")
            // TODO testing GPUImage - end
        }
        
        // Get location
        
        if server.location != nil {
            print("User location: (\(server.location!.coordinate.latitude), \(server.location!.coordinate.longitude))")
        } else {
            print("User didnt allow location")
        }
        
        // Send to server
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if self.imageContainer.image != nil {
                let imageData = UIImageJPEGRepresentation(self.imageContainer.image!, 0.5)
                
                var message_lat = ""
                var message_lng = ""
                var message_location_area = ""
                var message_location_country = ""
                var message_location_full_address = ""
                
                if server.location != nil {
                    message_lat = String(stringInterpolationSegment: server.location!.coordinate.latitude)
                    message_lng = String(stringInterpolationSegment: server.location!.coordinate.longitude)
                }
                
                if server.placemark != nil {
                    if let thoroughfare = server.placemark!.thoroughfare {
                        message_location_full_address += "\(thoroughfare), "
                    }
                    if let locality = server.placemark!.locality {
                        message_location_full_address += "\(locality) "
                    }
                    if let administrativeArea = server.placemark!.administrativeArea {
                        message_location_full_address += "\(administrativeArea) "
                    }
                    if let postalCode = server.placemark!.postalCode {
                        message_location_full_address += "\(postalCode) "
                    }
                    if let country = server.placemark!.country {
                        message_location_full_address += "\(country) "
                    }
                    
                    if let msg_location_area = server.placemark!.locality {
                        message_location_area = String(msg_location_area)
                    }
                    
                    if let msg_location_country = server.placemark!.country {
                        message_location_country = String(msg_location_country)
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
                
                let params: Dictionary<String, AnyObject> = ["image": Upload(data: imageData!, fileName: "upload.jpg", mimeType: "image/jpeg"), "lat": message_lat, "lng": message_lng, "location_area": message_location_area, "location_country": message_location_country, "location_full_address": message_location_full_address, "uid": uid, "token": token, "client": client]
                
                server.ping(self)
                
                do {
                    let opt = try HTTP.POST(server.http_url, parameters: params)
                
                    opt.start { response in
                        if let err = response.error {
                            print("error: \(err.localizedDescription)")
                            return //also notify app of failure as needed
                        }
                    
                        let str = NSString(data: response.data, encoding: NSUTF8StringEncoding)
                        print("response: \(str)") //prints the HTML of the page
                        
                        self.result = str!.dataUsingEncoding(NSUTF8StringEncoding)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("fromSendingPictureToResult", sender: nil)
                        }
                    }
                } catch let error {
                    print("got an error creating the request: \(error)")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.text = "Searching"
                }
            }
        }
        
        server.shouldSend = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromSendingPictureToResult" {
            if result != nil {
                let destination = segue.destinationViewController as! ResultViewController
                destination.result = result
                destination.saveToHistory = true
                result = nil
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
    
    func detectUsingCIDetector(image: UIImage, imageContainer: UIImageView) -> (UIImage?, UIImage?) {
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector.featuresInImage(CIImage(image: image)!)

        if features.count > 0 {
            for feature in features {
                if let rectangle_feature = feature as? CIRectangleFeature {
                    let top_left = rectangle_feature.topLeft
                    let top_right = rectangle_feature.topRight
                    let bottom_right = rectangle_feature.bottomRight
                    let bottom_left = rectangle_feature.bottomLeft

                    UIGraphicsBeginImageContext(image.size)
                    let context = UIGraphicsGetCurrentContext()

                    image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
                    
                    CGContextMoveToPoint(context, top_left.x, image.size.height-top_left.y)
                    CGContextAddLineToPoint(context, top_right.x, image.size.height-top_right.y)
                    
                    CGContextMoveToPoint(context, top_right.x, image.size.height-top_right.y)
                    CGContextAddLineToPoint(context, bottom_right.x, image.size.height-bottom_right.y)
                    
                    CGContextMoveToPoint(context, bottom_right.x, image.size.height-bottom_right.y)
                    CGContextAddLineToPoint(context, bottom_left.x, image.size.height-bottom_left.y)
                    
                    CGContextMoveToPoint(context, bottom_left.x, image.size.height-bottom_left.y)
                    CGContextAddLineToPoint(context, top_left.x, image.size.height-top_left.y)

                    CGContextSetLineCap(context, .Round)
                    CGContextSetLineWidth(context, 2.0)
                    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0)
                    CGContextSetBlendMode(context, .Normal)

                    CGContextStrokePath(context)
                    
                    let detectedImage = UIGraphicsGetImageFromCurrentImageContext()
                    
                    UIGraphicsEndImageContext()
                    
                    let ci_image = CIImage(image: image)
                    
                    let image_rect = ci_image!.imageByApplyingFilter("CIPerspectiveTransformWithExtent", withInputParameters: [
                            "inputExtent": CIVector(CGRect: ci_image!.extent),
                            "inputTopLeft": CIVector(CGPoint: top_left),
                            "inputTopRight": CIVector(CGPoint: top_right),
                            "inputBottomLeft": CIVector(CGPoint: bottom_left),
                            "inputBottomRight": CIVector(CGPoint: bottom_right)
                        ])
                    
                    let cropped_ci_image = ci_image?.imageByCroppingToRect(image_rect.extent)
                    let cg_image = CIContext(options:nil).createCGImage(cropped_ci_image!, fromRect: cropped_ci_image!.extent)
                    
                    let cropped_image = UIImage(CGImage: cg_image)
                    
                    return (detectedImage, cropped_image)
                    
                }
            }
        }

        return (nil, nil)
    }

}
