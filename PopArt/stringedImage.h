//
//  stringedImage.h
//  PopsArt
//
//  Created by Netronian Inc on 9/12/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface stringedImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *str;
@property (nonatomic, strong) NSArray *rects;
@property (nonatomic, strong) NSArray* keypoints;
@property (nonatomic, strong) UIImage* cropedImage;
@property (nonatomic, strong) UIImage* overlayImage;
@property (nonatomic, strong) UIImage* overlayImageWithImage;
//@property (nonatomic, strong) CGPoint* rectCenter;
@property (nonatomic, strong) NSNumber* rectArea;
@end
