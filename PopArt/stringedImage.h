//
//  stringedImage.h
//  PopsArt
//
//  Created by Bruno Garelli on 9/12/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface stringedImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *str;
@property (nonatomic, strong) NSArray *rects;
@property (nonatomic, strong) UIImage* cropedImage;
@end
