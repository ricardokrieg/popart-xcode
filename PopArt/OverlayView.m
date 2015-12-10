//
//  OverlayView.m
//  PopsArt
//
//  Created by User on 10.12.15.
//  Copyright © 2015 Netronian Inc. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

- (void)drawRect:(CGRect)rect {
    //[super drawRect:rect];
    for (NSArray* r in self.rects) {
        if (r.count > 0) {
            UIBezierPath* path = [UIBezierPath bezierPath];
            [path moveToPoint:[(NSValue *)[r objectAtIndex:0] CGPointValue]];
            for (NSInteger i = 1; i < r.count;i ++) {
                [path addLineToPoint:[(NSValue *)[r objectAtIndex:i] CGPointValue]];
            }
            [[UIColor greenColor] setStroke];
            [path closePath];
            NSLog(@"path: %@",path);
            path.lineWidth = 2.0f;
            [path stroke];
        }
        
    }
    
}

@end
