//
//  MomentBlockOutFilter.m
//  Moments
//
//  Created by Adam Juhasz on 9/18/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentBlockOutFilter.h"

@implementation MomentBlockOutFilter

CG_INLINE CGContextRef CGContextCreate(CGSize size)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(nil, size.width, size.height, 8, size.width * (CGColorSpaceGetNumberOfComponents(space) + 1), space, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);
    
    return ctx;
}

CG_INLINE UIImage* UIGraphicsGetImageFromContext(CGContextRef ctx)
{
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage* image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    return image;
}

- (NSUInteger)getRandomBlock
{
    NSUInteger blockNumber = floor(drand48() * ((numberOfBlocks*numberOfBlocks)-1));
    return blockNumber;
}

- (UIImage*)filteredImage
{
    if (image == nil)
        return nil;
    
    CGImageRef _image = image.CGImage;
    NSAssert(_image != NULL, @"imageref is null in bloc out filter");
    
    //set up draw environment
    CGSize imageSize = {CGImageGetWidth(_image),CGImageGetHeight(_image)};
    CGContextRef context = CGContextCreate(imageSize);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    //draw the original image
    CGRect wholeRect = {CGPointZero, imageSize};
    CGContextDrawImage(context, wholeRect, _image);
    
    //reset seed
    srand48(_seed);
    
    for (int i=0; i<self.filterValue*100; i++) {
        //get 2 random squares 0->(blockCount^2-1);
        NSUInteger block1Num = [self getRandomBlock];
        
        //grab block one
        CGPoint firstBlockCoordinate = {floor(block1Num/numberOfBlocks) * sizeOFBlock.width, (block1Num%numberOfBlocks) * sizeOFBlock.height};
        CGRect firstBlockRect = {firstBlockCoordinate,sizeOFBlock};
        firstBlockRect = CGRectInset(firstBlockRect, linesize, linesize);
        
        //draw block one in two
        CGContextFillRect(context, firstBlockRect);
    }
    
    //get final image
    UIImage *finalImage = UIGraphicsGetImageFromContext(context);
    CGContextRelease(context);
    
    return finalImage;
}

- (void)setFilterSettings:(NSDictionary *)filterSettings
{
    [super setFilterSettings:filterSettings];
    if (filterSettings == nil)
        return;
    
    if ([filterSettings objectForKey:@"blockCount"]) {
        NSNumber *newBlockCount = [filterSettings objectForKey:@"blockCount"];
        [self setBlockCount:[newBlockCount unsignedIntegerValue]];
    }
    
    if ([filterSettings objectForKey:@"seed"]) {
        NSNumber *newSeedCount = [filterSettings objectForKey:@"seed"];
        [self setSeed:[newSeedCount longValue]];
    }
}

- (NSDictionary*)filterSettings
{
    NSMutableDictionary *settings = [[super filterSettings] mutableCopy];
    if (settings == nil) {
        settings = [NSMutableDictionary dictionary];
    }
    
    [settings setObject:[NSNumber numberWithUnsignedInteger:numberOfBlocks] forKey:@"blockCount"];
    [settings setObject:[NSNumber numberWithLong:_seed] forKey:@"seed"];
    
    return settings;
}

@end
