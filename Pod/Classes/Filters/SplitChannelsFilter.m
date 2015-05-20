//
//  SplitChannelsFilter.m
//  moments
//
//  Created by Adam Juhasz on 11/6/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "SplitChannelsFilter.h"

@implementation SplitChannelsFilter

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *redColorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"]; // 2
    [redColorMatrixFilter setDefaults]; // 3
    [redColorMatrixFilter setValue:inputImage forKey:kCIInputImageKey]; // 4
    [redColorMatrixFilter setValue:[CIVector vectorWithX:1 Y:0 Z:0 W:0] forKey:@"inputRVector"]; // 5
    [redColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"]; // 6
    [redColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"]; // 7
    [redColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"]; // 8
    // Get the output image recipe
    redChannel = [redColorMatrixFilter outputImage];
    
    CIFilter *greenColorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"]; // 2
    [greenColorMatrixFilter setDefaults]; // 3
    [greenColorMatrixFilter setValue:inputImage forKey:kCIInputImageKey]; // 4
    [greenColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputRVector"]; // 5
    [greenColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"]; // 6
    [greenColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"]; // 7
    [greenColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"]; // 8
    // Get the output image recipe
    greenChannel = [greenColorMatrixFilter outputImage];  // 9
    
    CIFilter *blueColorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"]; // 2
    [blueColorMatrixFilter setDefaults]; // 3
    [blueColorMatrixFilter setValue:inputImage forKey:kCIInputImageKey]; // 4
    [blueColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputRVector"]; // 5
    [blueColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"]; // 6
    [blueColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:1 W:0] forKey:@"inputBVector"]; // 7
    [blueColorMatrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:1] forKey:@"inputAVector"]; // 8
    // Get the output image recipe
    blueChanel = [blueColorMatrixFilter outputImage];  // 9
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    
    pixelsToMove = (image.size.width * 0.33) * _filterValue;
    
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (image == nil) {
        return nil;
    }
    
    if (_cachedImage) {
        return _cachedImage;
    }
    
    CIFilter *redMove = [CIFilter filterWithName:@"CIAffineTransform"];
    [redMove setValue:redChannel forKey:@"inputImage"];
    NSValue *redTranslation = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(sinf(2*M_PI/3.0)*pixelsToMove, cosf(2*M_PI/3.0)*pixelsToMove)];
    [redMove setValue:redTranslation forKey:@"inputTransform"];
    CIImage *red = [redMove outputImage];
    
    CIFilter *greenMove = [CIFilter filterWithName:@"CIAffineTransform"];
    [greenMove setValue:greenChannel forKey:@"inputImage"];
    NSValue *greenTranslation = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(sinf(4*M_PI/3.0)*pixelsToMove, cosf(4*M_PI/3.0)*pixelsToMove)];
    [greenMove setValue:greenTranslation forKey:@"inputTransform"];
    CIImage *green = [greenMove outputImage];
    
    CIFilter *blueMove = [CIFilter filterWithName:@"CIAffineTransform"];
    [blueMove setValue:blueChanel forKey:@"inputImage"];
    NSValue *blueTranslation = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(sinf(0*M_PI/3.0)*pixelsToMove, cosf(0*M_PI/3.0)*pixelsToMove)];
    [blueMove setValue:blueTranslation forKey:@"inputTransform"];
    CIImage *blue = [blueMove outputImage];
    
    CIFilter *redAndGreenFilter = [CIFilter filterWithName:@"CIMaximumCompositing"];
    [redAndGreenFilter setValue:red forKey:kCIInputImageKey];
    [redAndGreenFilter setValue:green forKey:kCIInputBackgroundImageKey];
    CIImage *redAndGreen = [redAndGreenFilter outputImage];
    
    CIFilter *redAndGreenAndBlueFilter = [CIFilter filterWithName:@"CIMaximumCompositing"];
    [redAndGreenAndBlueFilter setValue:redAndGreen forKey:kCIInputImageKey];
    [redAndGreenAndBlueFilter setValue:blue forKey:kCIInputBackgroundImageKey];
    CIImage *allColors = [redAndGreenAndBlueFilter outputImage];
    
    CGRect intersection = CGRectIntersection(CGRectIntersection([red extent], [green extent]), [blue extent]);
    intersection.size.height = intersection.size.width = MIN(intersection.size.width, intersection.size.height);
    
    
    // Create the context and instruct CoreImage to draw the output image recipe into a CGImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:allColors fromRect:intersection]; // 10
    UIImage *filtered = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return filtered;
}
@end
