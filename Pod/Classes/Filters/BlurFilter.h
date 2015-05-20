//
//  BlurFilter.h
//  moments
//
//  Created by Adam Juhasz on 11/6/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"
#import <GPUImage/GPUImage.h>

@interface BlurFilter : MomentFilter
{
    GPUImageGaussianBlurFilter *blurFilter;
    GPUImagePicture *picture;
}
@end
