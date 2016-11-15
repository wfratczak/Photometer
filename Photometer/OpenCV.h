//
//  OpenCVManager.h
//  Photometer
//
//  Created by Wojtek Frątczak on 02.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <opencv2/opencv.hpp>

@interface OpenCV : NSObject

+ (NSString*)versionString;
+ (UIImage*)makeGrayscale:(UIImage*)rawImage;
+ (NSArray<NSNumber*>*) compareImage:(UIImage *)image with:(UIImage *)templateImage;

@end
