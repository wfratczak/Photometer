//
//  OpenCVManager.m
//  Photometer
//
//  Created by Wojtek Frątczak on 02.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

#import "OpenCV.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace cv;

@implementation OpenCV

+ (NSString*)versionString {
    return @CV_VERSION;
}

+ (UIImage*)makeGrayscale:(UIImage*)rawImage {
    cv::Mat imageMat;
    UIImageToMat(rawImage, imageMat);
    
    cv::Mat grayscaleMat;
    cv::cvtColor(imageMat, grayscaleMat, CV_BGR2GRAY);
    return MatToUIImage(grayscaleMat);
}

+ (NSArray<NSNumber*>*) compareImage:(UIImage *)image with:(UIImage *)templateImage
{
    Mat src_base, hsv_base;
    Mat src_test1, hsv_test1;
    
    UIImageToMat(image, src_base);
    UIImageToMat(templateImage, src_test1);
    
    /// Convert to HSV
    cvtColor( src_base, hsv_base, COLOR_BGR2HSV );
    cvtColor( src_test1, hsv_test1, COLOR_BGR2HSV );
    
    /// Using 50 bins for hue and 60 for saturation
    int h_bins = 50; int s_bins = 60;
    int histSize[] = { h_bins, s_bins };
    
    // hue varies from 0 to 179, saturation from 0 to 255
    float h_ranges[] = { 0, 180 };
    float s_ranges[] = { 0, 256 };
    
    const float* ranges[] = { h_ranges, s_ranges };
    
    // Use the o-th and 1-st channels
    int channels[] = { 0, 1 };
    
    
    /// Histograms
    MatND hist_base;
    MatND hist_test1;
    
    /// Calculate the histograms for the HSV images
    calcHist( &hsv_base, 1, channels, Mat(), hist_base, 2, histSize, ranges, true, false );
    normalize( hist_base, hist_base, 0, 1, NORM_MINMAX, -1, Mat() );
    
    calcHist( &hsv_test1, 1, channels, Mat(), hist_test1, 2, histSize, ranges, true, false );
    normalize( hist_test1, hist_test1, 0, 1, NORM_MINMAX, -1, Mat() );
    NSMutableArray *array = [@[] mutableCopy];
    /// Apply the histogram comparison methods
    for( int i = 0; i < 4; i++ )
    {
        int compare_method = i;
        double base_base = compareHist( hist_base, hist_base, compare_method );
        double base_test1 = compareHist( hist_base, hist_test1, compare_method );
        
        [array addObject:[NSNumber numberWithDouble:base_test1]];
        //printf( " Method [%d] Perfect, Base-Test(1) : %f, %f \n", i, base_base, base_test1 );
    }
    
    
    
//    cv::Mat imageMat;
//    cv::Mat templateImageMat;
//    UIImageToMat(image, imageMat);
//    UIImageToMat(templateImage, templateImageMat);
//
//    
//    cvCalcHist(<#IplImage **image#>, <#CvHistogram *hist#>)
//    
//    CvHistogram imageHistogram;
//    
//    //cvCompareHist(const CvHistogram *hist1, <#const CvHistogram *hist2#>, <#int method#>)
    return array;
}


@end
