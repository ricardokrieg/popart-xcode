//
//  Keypoint.h
//  PopsArt
//
//  Created by Netronian Inc on 11.12.15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Keypoint : NSObject

@property float angle;
@property int class_id;
@property int octave;
@property CGPoint pt;
@property float response;
@property float size;
@property NSMutableArray* descriptor;

@end