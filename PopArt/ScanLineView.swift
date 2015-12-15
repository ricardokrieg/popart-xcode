//
//  ScanLineView.swift
//  PopsArt
//
//  Created by Netronian Inc. on 15/12/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class ScanLineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        alpha = 0.0
        userInteractionEnabled = false
        
        backgroundColor = UIColor.cyanColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation(target: CGFloat) {
        alpha = 1.0
        
        frame.origin.x = 0.0
        UIView.animateWithDuration(3.0, delay: 0.0, options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
            self.frame.origin.x = target
        }, completion: nil)
    }
    
    func stopAnimation() {
        alpha = 0.0
    }
    
//    override func drawRect(rect: CGRect) {
////        let path = UIBezierPath()
////        path.moveToPoint(CGPointMake(0.0, 0.0))
////        path.addLineToPoint(CGPointMake(0.0, rect.height))
////        
////        UIColor.greenColor().setFill()
////        path.lineWidth = 4.0
////        path.fill()
//        
//        let context = UIGraphicsGetCurrentContext()
//        
//        CGContextMoveToPoint(context, 0, 0)
//        CGContextAddLineToPoint(context, 0, rect.height)
//        
//        CGContextSetLineCap(context, .Round)
//        CGContextSetLineWidth(context, rect.width)
//        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 1.0, 1.0)
//        CGContextSetBlendMode(context, .Normal)
//        
//        CGContextStrokePath(context)
//    }
}
