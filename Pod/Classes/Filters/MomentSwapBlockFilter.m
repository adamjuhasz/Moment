//
//  MomentSwapBlockFilter.m
//  Moments
//
//  Created by Adam Juhasz on 9/18/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentSwapBlockFilter.h"

@implementation MomentSwapBlockFilter

- (id) init
{
    self = [super init];
    if (self) {
        [self setBlockCount:10];
        [self setSeed:time(NULL)];
        linesize = 1;
    }
    return self;
}

- (void)setBlockCount:(NSUInteger)count
{
    if (count > 2) {
        numberOfBlocks = count;
        [self calculateBlockSize];
    }
    
    sizeOFBlock.width = 0;
    sizeOFBlock.height = 0;
}

- (void)calculateBlockSize
{
    if (image == nil)
        return;
    
    sizeOFBlock.width = image.size.width/numberOfBlocks;
    sizeOFBlock.height = image.size.height/numberOfBlocks;
}

- (void)setSeed:(long)newSeed
{
    _seed = newSeed;
    srand48(_seed);
}

- (void)setWithUIImage:(UIImage *)newImage;
{
    [super setWithUIImage:newImage];
    [self calculateBlockSize];
}

- (NSUInteger)getRandomBlock
{
    NSUInteger blockNumber = floor(drand48() * ((numberOfBlocks*numberOfBlocks)-1));
    return blockNumber;
}

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

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (image == nil)
        return nil;
    
    CGImageRef _image = image.CGImage;
    NSAssert(_image != NULL, @"cgimageref is null inside swapblock filter");
    
    //set up draw environment
    CGSize imageSize = {CGImageGetWidth(_image),CGImageGetHeight(_image)};
    //UIGraphicsBeginImageContext(imageSize);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextRef context = CGContextCreate(imageSize);
    
    //draw the original image
    CGRect wholeRect = {CGPointZero, imageSize};
    CGContextDrawImage(context, wholeRect, _image);
    
    //reset seed
    srand48(_seed);
    
    for (int i=0; i<self.filterValue*100; i++) {
        //get 2 random squares 0->(blockCount^2-1);
        NSUInteger block1Num = [self getRandomBlock];
        NSUInteger block2Num = [self getRandomBlock];
        while (block1Num == block2Num) {
            block2Num = [self getRandomBlock];
        }
        
        //grab block one
        CGPoint firstBlockCoordinate = {floor(block1Num/numberOfBlocks) * sizeOFBlock.width, (block1Num%numberOfBlocks) * sizeOFBlock.height};
        CGRect firstBlockRect = {firstBlockCoordinate,sizeOFBlock};
        firstBlockRect = CGRectInset(firstBlockRect, linesize, linesize);
        CGImageRef firstBlock = CGImageCreateWithImageInRect(_image, firstBlockRect);
        
        //grab block two
        CGPoint secondBlockCoordinate = {floor(block2Num/numberOfBlocks) * sizeOFBlock.width, (block2Num%numberOfBlocks) * sizeOFBlock.height};
        CGRect secondBlockRect = {secondBlockCoordinate,sizeOFBlock};
        secondBlockRect = CGRectInset(secondBlockRect, linesize, linesize);
        CGImageRef secondBlock = CGImageCreateWithImageInRect(_image, secondBlockRect);
        
        //draw block one in two
        CGContextDrawImage(context, secondBlockRect, firstBlock);
        
        //draw block two in one
        CGContextDrawImage(context, firstBlockRect, secondBlock);
        
        CGImageRelease(firstBlock);
        CGImageRelease(secondBlock);
    }
    
    //get final image
    //UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    UIImage *finalImage = UIGraphicsGetImageFromContext(context);
    CGContextRelease(context);
    
    //finalImage = [UIImage imageNamed:@"gear.png"];
    return finalImage;
}

- (void)setFilterSettings:(NSDictionary *)filterSettings
{
    [super setFilterSettings:filterSettings];
    if (filterSettings == nil)
        return;
    
    NSAssert(([filterSettings isKindOfClass:[NSDictionary class]] == YES), @"filter settings not a dictionary");
    
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
