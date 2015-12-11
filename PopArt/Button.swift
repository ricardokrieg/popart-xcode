//
//  Button.swift
//  PopsArt
//
//  Created by Netronian Inc. on 06/10/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class Button: UIButton {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 2
        self.backgroundColor = UIColor.clearColor()
        self.tintColor = UIColor.blackColor()
        self.contentEdgeInsets = UIEdgeInsetsMake(3.0, 0.0, 0.0, 0.0)
    }

}
