//
//  FadedFilter.h
//  moments
//
//  Created by Adam Juhasz on 11/5/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"
#import <GPUImage/GPUImage.h>

@interface FadedFilter : MomentFilter
{
    GPUImageFilterGroup *filters;
    GPUImagePicture *picture;
    GPUImageDissolveBlendFilter *finalDissolve;
}
@end
