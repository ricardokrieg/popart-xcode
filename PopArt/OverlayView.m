//
//  OverlayView.m
//  PopsArt
//
//  Created by Netronian Inc on 10.12.15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

//- (void)drawRect:(CGRect)rect {
    //[super drawRect:rect];
//    [[UIColor greenColor] set];
//    for (NSArray* r in self.rects) {
//        if (r.count > 0) {
//
//            for (NSInteger i = 0; i < 4; i++) {
//                CGPoint p0 = [[r objectAtIndex:i] CGPointValue];
//                CGPoint p1;
//                CGPoint p2;
//                if (i == 0) {
//                    p1 = [[r objectAtIndex:i+1] CGPointValue];
//                    p2 = [[r objectAtIndex:3] CGPointValue];
//                } else if (i == 3) {
//                    p1 = [[r objectAtIndex:0] CGPointValue];
//                    p2 = [[r objectAtIndex:i-1] CGPointValue];
//                } else {
//                    p1 = [[r objectAtIndex:i+1] CGPointValue];
//                    p2 = [[r objectAtIndex:i-1] CGPointValue];
//                }
//                UIBezierPath* path0 = [UIBezierPath bezierPath];
//                [path0 moveToPoint:p0];
//                [path0 addLineToPoint:CGPointMake(p0.x + 0.2*(p1.x - p0.x), p0.y + 0.2*(p1.y - p0.y))];
//                path0.lineWidth = 3.0;
//                [path0 stroke];
//                
//                UIBezierPath* path1 = [UIBezierPath bezierPath];
//                [path1 moveToPoint:p0];
//                [path1 addLineToPoint:CGPointMake(p0.x + 0.2*(p2.x - p0.x), p0.y + 0.2*(p2.y - p0.y))];
//                path1.lineWidth = 3.0;
//                [path1 stroke];
//            }
//            
//        }
//        
//    }
//     [[UIColor whiteColor] setFill];
//    if (self.keypoints) {
//        for (NSValue* v in self.keypoints) {
//            CGPoint p = [v CGPointValue];
//            UIBezierPath* point = [UIBezierPath bezierPathWithArcCenter:p radius:1.5 startAngle:0 endAngle:360 clockwise:YES];
//            [point fill];
//        }
//    }
//    if (self.overlayImage) {
//        [self.overlayImage drawInRect:rect];
//    }
//    
//}

@end
