//
//  CVWrapper.h
//  PopsArt
//
//  Created by Netronian Inc. on 05/12/15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVWrapper : NSObject

+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage;

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;

+ (UIImage*) processWithArray:(NSArray*)imageArray;


@end
