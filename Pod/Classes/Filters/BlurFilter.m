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
    
    [self filteredImage];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    [blurFilter useNextFrameForImageCapture];
    [picture processImageWithCompletionHandler:^{
        UIImage *filtered = [blurFilter imageFromCurrentFramebuffer];
        [self updateDelegateWithImage:filtered];
    }];
    
    return image;
}

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    picture = [[GPUImagePicture alloc] initWithImage:anImage];
    [picture addTarget:blurFilter];
}

@end
