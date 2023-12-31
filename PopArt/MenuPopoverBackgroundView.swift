//
//  MenuPopoverBackgroundView.swift
//  PopsArt
//
//  Created by Netronian Inc. on 03/09/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class MenuPopoverBackgroundView: UIPopoverBackgroundView {

    override var arrowOffset: CGFloat {
        get {return self.arrowOffset}
        
        set {}
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {return UIPopoverArrowDirection.Down}
        
        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 221, green: 221, blue: 221, alpha: 1.0)
        self.layer.shadowColor = UIColor(red: 221, green: 221, blue: 221, alpha: 0.0).CGColor
        
//        var arrowView = UIImageView(image: UIImage(named: "arrow"))
//        arrowView.frame = CGRect(x: 16.0, y: 140.0, width: 16.0, height: 9.0)
//        self.addSubview(arrowView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func wantsDefaultContentAppearance() -> Bool {
        return false
    }
    
    override class func contentViewInsets() -> UIEdgeInsets{
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override class func arrowHeight() -> CGFloat {
        return 0.0
    }
    
    override class func arrowBase() -> CGFloat{
        return 0.0
    }

}
