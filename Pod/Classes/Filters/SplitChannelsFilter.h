//
//  SplitChannelsFilter.h
//  moments
//
//  Created by Adam Juhasz on 11/6/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"

@interface SplitChannelsFilter : MomentFilter
{
    CIImage *redChannel;
    CIImage *greenChannel;
    CIImage *blueChanel;
    
    CGFloat pixelsToMove;
}
@end
