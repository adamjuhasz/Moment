//
//  BrightExposureFilter.m
//  Pods
//
//  Created by Adam Juhasz on 6/14/15.
//
//

#import "BrightExposureFilter.h"
#import <GPUImage/GPUImage.h>

@interface BrightExposureFilter ()
{
    GPUImageExposureFilter *exposureFilter;
    GPUImagePicture *picture;
}
@end

@implementation BrightExposureFilter

- (id)init
{
    self = [super init];
    if (self) {
        exposureFilter = [[GPUImageExposureFilter alloc] init];
    }
    return self;
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    
    exposureFilter.exposure = (filterValue * 10.0);
    
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    [exposureFilter useNextFrameForImageCapture];
    [picture processImage];
    
    UIImage *filtered = [exposureFilter imageFromCurrentFramebuffer];
    return filtered;
}

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    picture = [[GPUImagePicture alloc] initWithImage:anImage];
    [picture addTarget:exposureFilter];
}

@end
