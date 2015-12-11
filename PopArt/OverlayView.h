//
//  OverlayView.h
//  PopsArt
//
//  Created by Netronian Inc on 10.12.15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView

@property (strong) NSArray* rects;
@property (strong,nonatomic) NSArray* keypoints;
@property (strong,nonatomic) UIImage* overlayImage;
@end
