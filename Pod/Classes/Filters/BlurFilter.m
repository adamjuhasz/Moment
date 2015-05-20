//
//  BlurFilter.m
//  moments
//
//  Created by Adam Juhasz on 11/6/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "BlurFilter.h"

@implementation BlurFilter

- (id)init
{
    self = [super init];
    if (self) {
        blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        [blurFilter useNextFrameForImageCapture];
    }
    return self;
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    
    CGFloat radius = 10*filterValue;
    blurFilter.blurRadiusInPixels = radius;
    
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    [blurFilter useNextFrameForImageCapture];
    [picture processImage];
    
    UIImage *filtered = [blurFilter imageFromCurrentFramebuffer];
    return filtered;
}

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    picture = [[GPUImagePicture alloc] initWithImage:anImage];
    [picture addTarget:blurFilter];
}



@end
