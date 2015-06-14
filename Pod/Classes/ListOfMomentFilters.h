//
//  ListOfMomentFilters.h
//  Moments
//
//  Created by Adam Juhasz on 9/26/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"
#import "MomentGlitchFilter.h"
#import "MomentSwapBlockFilter.h"
#import "MomentBlockOutFilter.h"
#import "MomentLightleakFilter.h"
#import "FadedFilter.h"
#import "SplitChannelsFilter.h"
#import "GrayScaleFilter.h"
#import "BlurFilter.h"
#import "PixelateFilter.h"
#import "BrightExposureFilter.h"

#ifndef Moments_ListOfMomentFilters_h
#define Moments_ListOfMomentFilters_h

#define ArrayOfAllMomentFilters @[@"none", @"swapBlock", @"blockOut", @"leak", @"faded", @"split", GrayScaleFilterName, PixelateFilterName, BrightExposureFilterName, BlurFilterName]; //@"glitch"

#endif
