//
//  SimilarPaintingView.swift
//  PopsArt
//
//  Created by Netronian Inc. on 15/12/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

import UIKit

class SimilarPaintingView: UIView, UIGestureRecognizerDelegate {
    var painting: NSDictionary?
    var host: ResultViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap"))
//        tap.cancelsTouchesInView = false
//        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func handleTap() {
        NSLog("Tap: \(painting)")
        
        host?.paintingToModal = painting
        host?.performSegueWithIdentifier("fromResultToResultModal", sender: nil)
    }
}
