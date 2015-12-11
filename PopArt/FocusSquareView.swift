//
//  FocusSquareView.swift
//  PopsArt
//
//  Created by Netronian Inc. on 17/09/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class FocusSquareView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        userInteractionEnabled = false
        
        backgroundColor = UIColor.clearColor()
        layer.borderWidth = 2.0
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor.greenColor().CGColor
        alpha = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
