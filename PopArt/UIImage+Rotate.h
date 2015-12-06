//
//  UIImage+Rotate.h
//  PopsArt
//
//  Created by Netronian Inc. on 05/12/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotate)

//faster, alters the exif flag but doesn't change the pixel data
- (UIImage*)rotateExifToOrientation:(UIImageOrientation)orientation;


//slower, rotates the actual pixel matrix
- (UIImage*)rotateBitmapToOrientation:(UIImageOrientation)orientation;

- (UIImage*)rotateToImageOrientation;

@end