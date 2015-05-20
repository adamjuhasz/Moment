//
//  MomentSwapBlockFilter.h
//  Moments
//
//  Created by Adam Juhasz on 9/18/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"

@interface MomentSwapBlockFilter : MomentFilter
{
    NSUInteger numberOfBlocks;
    long _seed;
    CGSize sizeOFBlock;
    int linesize;
}

- (void)setBlockCount:(NSUInteger)count;
- (void)setSeed:(long)newSeed;

@end
