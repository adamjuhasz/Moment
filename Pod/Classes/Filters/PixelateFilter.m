//
//  PixelateFilter.m
//  Pods
//
//  Created by Adam Juhasz on 6/14/15.
//
//

#import "PixelateFilter.h"
#import <GPUImage/GPUImage.h>

@interface PixelateFilter ()
{
    GPUImagePixellateFilter *pixelator;
    GPUImagePicture *picture;
}
@end

@implementation PixelateFilter

- (id)init
{
    self = [super init];
    if (self) {
        pixelator = [[GPUImagePixellateFilter alloc] init];
    }
    return self;
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    
    
    CGSize imageSize = [image size];
    CGFloat width = imageSize.width;
    CGFloat pixelsWanted = (width-1) * (1-filterValue) + 1;
    pixelsWanted = roundf(pixelsWanted);
    CGFloat fraction = 1 / pixelsWanted;
    
    fraction = MIN(fraction, 1.0);
    fraction = MAX(fraction, 0.0);
    
    pixelator.fractionalWidthOfAPixel =  fraction;
    
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    [pixelator useNextFrameForImageCapture];
    [picture processImage];
    
    UIImage *filtered = [pixelator imageFromCurrentFramebuffer];
    return filtered;
}

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    picture = [[GPUImagePicture alloc] initWithImage:anImage];
    [picture addTarget:pixelator];
}


@end
