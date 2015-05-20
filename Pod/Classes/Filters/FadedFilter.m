//
//  FadedFilter.m
//  moments
//
//  Created by Adam Juhasz on 11/5/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "FadedFilter.h"

@implementation FadedFilter

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)setFilter
{
    filters = [[GPUImageFilterGroup alloc] init];
    
    GPUImageFalseColorFilter *gradient = [[GPUImageFalseColorFilter alloc] init];
    GPUVector4 Blue = (GPUVector4){50/255.0f, 102/255.0f, 177/255.0f, 1.0f};
    GPUVector4 Yellow = (GPUVector4){254/255.0f, 244/255.0f, 57/255.0f, 1.0f};
    gradient.firstColor = Blue;
    gradient.secondColor = Yellow;
    [filters addFilter:gradient];
    
    GPUImageDissolveBlendFilter *mixer = [[GPUImageDissolveBlendFilter alloc] init];
    mixer.mix = 0.3;
    [picture addTarget:mixer atTextureLocation:0];
    [gradient addTarget:mixer atTextureLocation:1];
    [filters addFilter:mixer];
    
    GPUImageBrightnessFilter *brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = -0.3;
    [mixer addTarget:brightness];
    [filters addFilter:brightness];
    
    GPUImageContrastFilter *contrast = [[GPUImageContrastFilter alloc] init];
    contrast.contrast = 2.0;
    [brightness addTarget:contrast];
    [filters addFilter:contrast];
    
    GPUImageVignetteFilter *vignette = [[GPUImageVignetteFilter alloc] init];
    [contrast addTarget:vignette];
    [filters addFilter:vignette];
    
    [filters setInitialFilters:[NSArray arrayWithObject:[filters filterAtIndex:0]]];
    [filters setTerminalFilter:[filters filterAtIndex:[filters filterCount]-1]];
    [picture addTarget:filters];
    
    finalDissolve = [[GPUImageDissolveBlendFilter alloc] init];
    finalDissolve.mix = self.filterValue;
    [picture addTarget:finalDissolve atTextureLocation:0];
    [filters addTarget:finalDissolve atTextureLocation:1];
}

- (void)setWithUIImage:(UIImage *)anImage
{
    [super setWithUIImage:anImage];
    
    picture = [[GPUImagePicture alloc] initWithImage:anImage];
    [self setFilter];
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    
    finalDissolve.mix = _filterValue;
    
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    [filters useNextFrameForImageCapture];
    [finalDissolve useNextFrameForImageCapture];
    [picture processImage];
    
    UIImage *filtered = [finalDissolve imageFromCurrentFramebuffer];
    return filtered;
}

@end
