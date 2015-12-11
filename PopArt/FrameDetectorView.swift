//
//  FrameDetector.swift
//  PopsArt
//
//  Created by Netronian Inc. on 17/09/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit
import Foundation
import GPUImage
import CoreImage

class FrameDetectorView: UIView {
    var topLeft: CGPoint?
    var topRight: CGPoint?
    var bottomLeft: CGPoint?
    var bottomRight: CGPoint?
    var imagesize: CGSize?
    
    let detector:CIDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
    
    override func drawRect(rect: CGRect) {
        if topLeft != nil {
            let context = UIGraphicsGetCurrentContext()
            
//            CGContextSetLineWidth(context, 2.0)
//            
//            let colorSpace = CGColorSpaceCreateDeviceRGB()
//            let components: [CGFloat] = [0.0, 0.0, 1.0, 1.0]
//            let color = CGColorCreate(colorSpace, components)
//            
//            CGContextSetStrokeColorWithColor(context, color)
            let dif = ((imagesize?.height)! - self.frame.size.height)
            
            CGContextMoveToPoint(context, topLeft!.x, bounds.height-topLeft!.y+dif)
            CGContextAddLineToPoint(context, topRight!.x, bounds.height-topRight!.y+dif)
            
            CGContextMoveToPoint(context, topRight!.x, bounds.height-topRight!.y+dif)
            CGContextAddLineToPoint(context, bottomRight!.x, bounds.height-bottomRight!.y+dif)
            
            CGContextMoveToPoint(context, bottomRight!.x, bounds.height-bottomRight!.y+dif)
            CGContextAddLineToPoint(context, bottomLeft!.x, bounds.height-bottomLeft!.y+dif)
            
            CGContextMoveToPoint(context, bottomLeft!.x, bounds.height-bottomLeft!.y+dif)
            CGContextAddLineToPoint(context, topLeft!.x, bounds.height-topLeft!.y+dif)
            
            CGContextSetLineCap(context, .Round)
            CGContextSetLineWidth(context, 2.0)
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0)
            CGContextSetBlendMode(context, .Normal)
            
            CGContextStrokePath(context)
        }
    }
    
    func detectUsingCIDetector(image: UIImage) -> (UIImage?, UIImage?, String?, CGPoint?, CGPoint?, CGPoint?, CGPoint?) {
        
        let features = detector.featuresInImage(CIImage(image: image)!)
        
        return (nil, nil, nil, nil, nil, nil, nil)
        
        var detectMessage: String? = nil
        print(features.count)
        
        if features.count > 0 {
            for feature in features {
                if let rectangle_feature = feature as? CIRectangleFeature {
                    let top_left = rectangle_feature.topLeft
                    let top_right = rectangle_feature.topRight
                    let bottom_right = rectangle_feature.bottomRight
                    let bottom_left = rectangle_feature.bottomLeft
                    
                    let frame_width = sqrt(pow(top_left.x-top_right.x,2)+pow(top_left.y-top_right.y,2))
                    let frame_height = sqrt(pow(top_left.x-bottom_left.x,2)+pow(top_left.y-bottom_left.y,2))
                    
                    if frame_width / image.size.width < 0.8 && frame_height / image.size.height < 0.8 {
                        detectMessage = "Please, get near to the painting"
                    }
                    print(image.size)
                    print(self.frame)
//                    let newRect = CALayer()
////                    newRect.frame = CGRectMake(50, 50, 100, 100)
//                    newRect.frame = CGRectMake(top_left.x, previewLayer.bounds.size.height-top_left.y, frame_width, frame_height)
//                    newRect.borderColor = UIColor.redColor().CGColor
//                    newRect.borderWidth = 1;
//                    previewLayer.addSublayer(newRect)
                    
                    
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
                    
                    let croppedImage = UIImage(CGImage: cg_image)
                    
                    return (detectedImage, croppedImage, detectMessage, top_left, top_right, bottom_left, bottom_right)
                }
            }
        }else
        {
          //  previewLayer.sublayers = nil;
        }
        
        return (nil, nil, detectMessage, nil, nil, nil, nil)
    }
    
    class func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}


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
