//
//  GrayScaleFilter.m
//  Pods
//
//  Created by Adam Juhasz on 6/14/15.
//
//

#import "GrayScaleFilter.h"
#import <GPUImage/GPUImage.h>

@interface GrayScaleFilter ()
{
    GPUImageSaturationFilter *saturationFilter;
    GPUImageContrastFilter *contrastFilter;
    GPUImagePicture *picture;
}
@end

@implementation GrayScaleFilter

- (id)init
{
    self = [super init];
    if (self) {
        saturationFilter = [[GPUImageSaturationFilter alloc] init];
        
        contrastFilter = [[GPUImageContrastFilter alloc] init];
        [saturationFilter addTarget:contrastFilter];
    }
    return self;
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    
    CGFloat cutoff = 0.3;
    if (filterValue <= cutoff) {
        saturationFilter.saturation = 1.0 - filterValue*(1/cutoff);
        contrastFilter.contrast = 1.0;
    } else {
        saturationFilter.saturation = 0.0;
        contrastFilter.contrast = (4.0-1.0)*(1/(1-cutoff))*(filterValue - cutoff) + 1.0;
    }
    
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    [saturationFilter useNextFrameForImageCapture];
    [contrastFilter useNextFrameForImageCapture];
    [picture processImage];
    
    UIImage *filtered = [contrastFilter imageFromCurrentFramebuffer];
    return filtered;
}

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    picture = [[GPUImagePicture alloc] initWithImage:anImage];
    [picture addTarget:saturationFilter];
}

@end
