//
//  CVWrapper.m
//  PopsArt
//
//  Created by Netronian Inc. on 05/12/15.
//  Copyright © 2015 Art Catch. All rights reserved.
//

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
#import "stitching.h"
#import "UIImage+Rotate.h"
#import <opencv2/features2d.hpp>
#import <Foundation/Foundation.h>


@implementation CVWrapper

// helper function:
// finds a cosine of angle between vectors
// from pt0->pt1 and from pt0->pt2
static double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 )
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

+ (stringedImage*) processImageWithOpenCV: (UIImage*) inputImage
{
//    NSArray* imageArray = [NSArray arrayWithObject:inputImage];
//    UIImage* result = [[self class] processWithArray:imageArray];
//    return result;
    
    UIImage* rotatedImage = [inputImage rotateToImageOrientation];
    cv::Mat image = [rotatedImage CVMat3];
    
    std::vector<std::vector<cv::Point>>squares;
    std::vector<cv::Point> largest_square;
    find_squares(image, squares);
    find_largest_square(squares, largest_square);
    

    for (int i = 0; i < squares.size(); i++) {
        std::vector<cv::Point> squre = squares[i];
        if (squre.size() == 4) {
            line(image, squre[0], squre[1], cv::Scalar(0,255,0));
            line(image, squre[1], squre[2], cv::Scalar(0,255,0));
            line(image, squre[2], squre[3], cv::Scalar(0,255,0));
            line(image, squre[3], squre[0], cv::Scalar(0,255,0));
        }
    }
        
//    NSLog (@"matImage: %@",inputImage);
    
//    int thresh = 100, N = 11;
//    
//    std::vector<std::vector<cv::Point> > squares;
//    cv::Mat pyr, timg, gray0(image.size(), CV_8U), gray;
//    
//    // down-scale and upscale the image to filter out the noise
//    pyrDown(image, pyr, cv::Size(image.cols/2, image.rows/2));
//    pyrUp(pyr, timg, image.size());
//    std::vector<std::vector<cv::Point> > contours;
//    
//    // find squares in every color plane of the image
//    for( int c = 0; c < 3; c++ )
//    {
//        int ch[] = {c, 0};
//        mixChannels(&timg, 1, &gray0, 1, ch, 1);
//        
//        // try several threshold levels
//        for( int l = 0; l < N; l++ )
//        {
//            // hack: use Canny instead of zero threshold level.
//            // Canny helps to catch squares with gradient shading
//            if( l == 0 )
//            {
//                // apply Canny. Take the upper threshold from slider
//                // and set the lower to 0 (which forces edges merging)
//                Canny(gray0, gray, 0, thresh, 5);
//                // dilate canny output to remove potential
//                // holes between edge segments
//                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
//            }
//            else
//            {
//                // apply threshold if l!=0:
//                //     tgray(x,y) = gray(x,y) < (l+1)*255/N ? 255 : 0
//                gray = gray0 >= (l+1)*255/N;
//            }
//            
//            // find contours and store them all as a list
//            cv::findContours(gray, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
//            
//            std::vector<cv::Point> approx;
//            
//            // test each contour
//            for( size_t i = 0; i < contours.size(); i++ )
//            {
//                // approximate contour with accuracy proportional
//                // to the contour perimeter
//                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
//                
//                // square contours should have 4 vertices after approximation
//                // relatively large area (to filter out noisy contours)
//                // and be convex.
//                // Note: absolute value of an area is used because
//                // area may be positive or negative - in accordance with the
//                // contour orientation
//                if( approx.size() == 4 &&
//                   fabs(contourArea(cv::Mat(approx))) > 1000 &&
//                   isContourConvex(cv::Mat(approx)) )
//                {
//                    double maxCosine = 0;
//                    
//                    for( int j = 2; j < 5; j++ )
//                    {
//                        // find the maximum cosine of the angle between joint edges
//                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
//                        maxCosine = MAX(maxCosine, cosine);
//                    }
//                    
//                    // if cosines of all angles are small
//                    // (all angles are ~90 degree) then write quandrange
//                    // vertices to resultant sequence
//                    if( maxCosine < 0.3 )
//                        squares.push_back(approx);
//                }
//            }
//        }
//    }
//    
//    for( size_t i = 0; i < squares.size(); i++ ) {
//        const cv::Point* p = &squares[i][0];
//        int n = (int)squares[i].size();
//        polylines(image, &p, &n, 1, true, cv::Scalar(0,255,0), 3, cv::LINE_AA);
//    }
    
//    cv::Mat gray;
//    cv::cvtColor(matImage, gray, CV_BGR2GRAY);
//    cv::blur(gray, gray, cv::Size(3, 3));
//    cv::Canny(gray, gray, 100, 100, 3);
    
    
    
    stringedImage* result =  [[stringedImage alloc] init];
    result.image = [UIImage imageWithCVMat:image];
    result.str = squares.size()>0 ?@"size": @"";
    if (largest_square.size() == 4) {
        cv::Mat croped = cropImage(image, largest_square);
        

        NSArray* keys = [CVWrapper detectKeypointWithUIImage:rotatedImage];
        NSMutableArray* keypoints = [NSMutableArray array];
        cv::Mat origin = rotatedImage.CVMat;
        cv::Mat overlay(origin.rows,origin.cols,CV_8UC4);
        overlay = cv::Scalar(255,255,255,0);
        if (largest_square.size() == 4) {
            for (int i = 0; i < 4; i++) {
                cv::Point2f p0 = largest_square[i];
                cv::Point2f p1;
                cv::Point2f p2;
                if (i == 0) {
                    p1 = largest_square[i+1];
                    p2 = largest_square[3];
                } else if (i == 3) {
                    p1 = largest_square[0];
                    p2 = largest_square[i-1];
                } else {
                    p1 = largest_square[i+1];
                    p2 = largest_square[i-1];
                }
                cv::line(overlay, p0, cv::Point2f(p0.x + 0.2*(p1.x - p0.x),p0.y + 0.2*(p1.y - p0.y)), cv::Scalar(0,255,0,255),6);
                cv::line(overlay, p0, cv::Point2f(p0.x + 0.2*(p2.x - p0.x),p0.y + 0.2*(p2.y - p0.y)), cv::Scalar(0,255,0,255),6);
            }
        }
        
        for (Keypoint* k in keys) {
            cv::Point2f p(k.pt.x,k.pt.y);
            if (containPointInRect(largest_square, p)) {
                [keypoints addObject:[NSValue valueWithCGPoint:k.pt]];
                cv::circle(overlay, p, 2, cv::Scalar(0,255,0,255),2);
            }
        }
        
        
        result.overlayImage = [UIImage imageWithCVMat:overlay];
        result.keypoints = keypoints;
        result.cropedImage = [UIImage imageWithCVMat:croped];
    }
    
    
    
//    NSMutableArray* rects = [NSMutableArray array];
//    for (int i = 0; i < squares.size(); i++) {
//        std::vector<cv::Point> sq = squares[i];
//        NSMutableArray* rect = [NSMutableArray array];
//        for (int j = 0; j < sq.size(); j++) {
//            NSLog(@"x: %i y: %i",sq[j].x, sq[j].y);
//            [rect addObject:[NSValue valueWithCGPoint:CGPointMake(sq[j].x, sq[j].y)]];
//        }
//        [rects addObject:rect];
//    }
    NSMutableArray* rect = [NSMutableArray array];
    for (int j = 0; j < largest_square.size(); j++) {
        NSLog(@"x: %i y: %i",largest_square[j].x, largest_square[j].y);
        [rect addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[j].x, largest_square[j].y)]];
        
    }
    result.rects = @[rect];
    return result;
}

+ (NSArray*)detectKeypointWithUIImage:(UIImage*)image {
    cv::Mat cvImage = image.CVMat;
    cv::Ptr<cv::ORB> orb = cv::ORB::create();
    
    std::vector<cv::KeyPoint> keypoints;
    cv::Mat desc;
    orb->detectAndCompute(cvImage, cv::noArray(), keypoints, desc);
    NSMutableArray* keyPointsArray = [NSMutableArray array];
    for (int i = 0; i < keypoints.size(); i++) {
        cv::KeyPoint key = keypoints[i];
        Keypoint* k = [Keypoint new];
        k.angle = key.angle;
        k.class_id = key.class_id;
        k.octave = key.octave;
        k.pt = CGPointMake(key.pt.x, key.pt.y);
        k.response = key.response;
        k.size = key.size;
        [keyPointsArray addObject:k];
    }
    
    return keyPointsArray;
}

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;
{
    NSArray* imageArray = [NSArray arrayWithObjects:inputImage1,inputImage2,nil];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithArray:(NSArray*)imageArray
{
    if ([imageArray count]==0){
        NSLog (@"imageArray is empty");
        return 0;
    }
    std::vector<cv::Mat> matImages;
    
    for (id image in imageArray) {
        if ([image isKindOfClass: [UIImage class]]) {
            /*
             All images taken with the iPhone/iPa cameras are LANDSCAPE LEFT orientation. The  UIImage imageOrientation flag is an instruction to the OS to transform the image during display only. When we feed images into openCV, they need to be the actual orientation that we expect them to be for stitching. So we rotate the actual pixel matrix here if required.
             */
            UIImage* rotatedImage = [image rotateToImageOrientation];
            cv::Mat matImage = [rotatedImage CVMat3];
            NSLog (@"matImage: %@",image);
            matImages.push_back(matImage);
        }
    }
    NSLog (@"stitching...");
    cv::Mat stitchedMat = stitch (matImages);
    UIImage* result =  [UIImage imageWithCVMat:stitchedMat];
    return result;
}

void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point>>&squares) {
    
    // blur will enhance edge detection
    
    cv::Mat blurred(image);
    //    medianBlur(image, blurred, 9);
    GaussianBlur(image, blurred, cvSize(11,11), 0);//change from median blur to gaussian for more accuracy of square detection
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
                Canny(gray0, gray, 10, 20, 3); //
                //                Canny(gray0, gray, 0, 50, 5);
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
}

void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
    if (!squares.size())
    {
        // no squares detected
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    
    for (size_t i = 0; i < squares.size(); i++)
    {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
        
        //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
        {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}

cv::Mat cropImage(cv::Mat &original,std::vector<cv::Point> &square) {
    CGPoint ptBottomLeft = CGPointMake(square[3].x, square[3].y);
    CGPoint ptBottomRight = CGPointMake(square[2].x, square[2].y);
    CGPoint ptTopRight = CGPointMake(square[1].x, square[1].y);
    CGPoint ptTopLeft = CGPointMake(square[0].x, square[0].y);
    
    CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
    CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
    
    CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
    CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
    
    CGFloat maxWidth = (w1 < w2) ? w1 : w2;
    CGFloat maxHeight = (h1 < h2) ? h1 : h2;
    
    cv::Point2f src[4], dst[4];
    
    src[0].x = ptTopLeft.x;
    src[0].y = ptTopLeft.y;
    src[1].x = ptTopRight.x;
    src[1].y = ptTopRight.y;
    src[2].x = ptBottomRight.x;
    src[2].y = ptBottomRight.y;
    src[3].x = ptBottomLeft.x;
    src[3].y = ptBottomLeft.y;
    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = maxWidth - 1;
    dst[1].y = 0;
    dst[2].x = maxWidth - 1;
    dst[2].y = maxHeight - 1;
    dst[3].x = 0;
    dst[3].y = maxHeight - 1;
    
    cv::Mat undistorted = cv::Mat( cvSize(maxWidth,maxHeight), CV_8UC4);
    
    NSLog(@"%f %f %f %f",ptBottomLeft.x,ptBottomRight.x,ptTopRight.x,ptTopLeft.x);
    cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
    
    return undistorted;
}

bool containPointInRect(std::vector<cv::Point> rect, cv::Point2f point) {
    double S1 = areaTriangle(rect[0], rect[1], rect[2]);
    double S2 = areaTriangle(rect[2], rect[3], rect[0]);
    
    double pS1 = areaTriangle(rect[0], rect[1], point);
    double pS2 = areaTriangle(rect[1], rect[2], point);
    double pS3 = areaTriangle(rect[2], rect[0], point);
    
    double pS4 = areaTriangle(rect[2], rect[3], point);
    double pS5 = areaTriangle(rect[3], rect[0], point);
    double pS6 = areaTriangle(rect[0], rect[2], point);
    if (fabs((S1 - (pS1 + pS2 + pS3))) < 0.1 || fabs((S2 - (pS4 + pS5 + pS6))) < 0.1) {
        return true;
    }
    
    return false;
}

double areaTriangle(cv::Point2f a, cv::Point2f b,cv::Point2f c) {
    double sideA = sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
    double sideB = sqrt(pow((b.x - c.x), 2) + pow((b.y - c.y), 2));
    double sideC = sqrt(pow((c.x - a.x), 2) + pow((c.y - a.y), 2));
    double p = (sideA + sideB + sideC) / 2;
    double s = sqrt(p*(p - sideA)*(p - sideB)*(p - sideC));
    return s;
}


@end