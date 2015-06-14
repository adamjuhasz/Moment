//
//  MomentFilter.m
//  MomentImage
//
//  Created by Adam Juhasz on 7/29/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"
#import "ListOfMomentFilters.h"

@implementation MomentFilter

- (id)init
{
    self = [super init];
    if (self) {
        _filterSteps = 100;
        self.filterSettings = [NSDictionary dictionary];
    }
    return self;
}

- (void)setWithUIImage:(UIImage *)newImage
{
    image = newImage;
    _cachedImage = nil;
}

- (void) setFilterValue:(float)filterValue
{
    filterValue = MAX(0.0, filterValue);
    filterValue = MIN(1.0, filterValue);
    
    _filterValue = filterValue;
    _cachedImage = nil;
    
    //if we are not subclassed we need to tell the delegate to do its work
    if ([self class] == [MomentFilter class]) {
        [self updateDelegateWithImage:self.filteredImage];
    }
}

- (float)filterValue
{
    return _filterValue;
}

- (UIImage*)filteredImage
{
    return image;
}

- (void)randomizeSettings
{
    return;
}

- (void) updateDelegateWithImage:(UIImage *)anImage
{
    UIImage *imageToSend = anImage;
    if (imageToSend == nil) {
        imageToSend = _cachedImage;
    } else {
        _cachedImage = imageToSend;
    }
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate momentFilter:self hasNewFilteredImage:imageToSend];
    });
}

- (void)dealloc
{

}

+(MomentFilter*)filterWithName:(NSString *)string
{
    return [[self class] filterWithName:string withZone:NSDefaultMallocZone()];
}

+(MomentFilter*)filterWithName:(NSString *)string withZone:(NSZone*)zone
{
    MomentFilter *filter = nil;
    
    //pick the right filter
    if ([string isEqualToString:@"none"]) {
        filter = [[MomentFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:@"glitch"]) {
        filter = [[MomentGlitchFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:@"swapBlock"]) {
        filter = [[MomentSwapBlockFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:@"blockOut"]) {
        filter = [[MomentBlockOutFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:@"leak"]) {
        filter = [[MomentLightleakFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:@"faded"]) {
        filter = [[FadedFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:@"split"]) {
        filter = [[SplitChannelsFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:GrayScaleFilterName]) {
        filter = [[GrayScaleFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:BlurFilterName]) {
        filter = [[BlurFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:PixelateFilterName]) {
        filter = [[PixelateFilter allocWithZone:zone] init];
    } else if ([string isEqualToString:BrightExposureFilterName]) {
        filter = [[BrightExposureFilter allocWithZone:zone] init];
    } else {
        filter = [[MomentFilter allocWithZone:zone] init];
    }
    
    if (filter) {
        filter.filterName = string;
    }
    
    return filter;
}

- (void)setDelegate:(id<MomentFilterDelegate>)delegate
{
    _delegate = delegate;
}

- (id<MomentFilterDelegate>)delegate
{
    return _delegate;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<MomentFilter 0x%08X> name: %@; value: %f; delegate: %@",
            (unsigned)self,
            self.filterName,
            self.filterValue,
            self.delegate];
}

-(id)copyWithZone:(NSZone *)zone
{
    MomentFilter *newFilter = [MomentFilter filterWithName:self.filterName withZone:zone];
    newFilter.filterSettings = self.filterSettings;
    [newFilter setWithUIImage:image];
    return newFilter;
}

@end
