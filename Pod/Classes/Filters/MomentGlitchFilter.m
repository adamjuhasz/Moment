//
//  MomentGlitchFilter.m
//  MomentImage
//
//  Created by Adam Juhasz on 7/29/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentGlitchFilter.h"

@interface MomentGlitchFilter ()
{
    NSData *jpegData;
    int headerSize;
    UIImage *filteredImage;
    long _seed;
}
@end

@implementation MomentGlitchFilter

- (id) init
{
    self = [super init];
    if (self) {
        [self setQuality:0.5];
        [self randomizeSettings];
    }
    return self;
}

- (void)seedWith:(long)seed
{
    _seed = seed;
}

- (void)setQuality:(float)quality
{
    self.jpegQuality = quality;
}

- (void)setWithUIImage:(UIImage *)newImage
{
    [super setWithUIImage:newImage];
    jpegData = UIImageJPEGRepresentation(image, self.jpegQuality);
    headerSize = [self findJpegHeaderSize];
}

- (int)findJpegHeaderSize
{
    Byte *byte_array = (Byte*)malloc([jpegData length]);
    memcpy(byte_array, [jpegData bytes], [jpegData length]);
    for (int i=0; i<[jpegData length]-1; i++) {
        if (byte_array[i] == 0xFF && byte_array[i+1] == 0xDA) {
            free(byte_array);
            return (i+2) + 417;
        }
    }
    free(byte_array);
    return 0;
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
    if (jpegData == nil) {
        return;
    }
    NSData *currentData = jpegData;
    int iterations = 50*filterValue;
    
    srand((unsigned int)_seed);
    
    //NSLog(@"filter: %f iterations: %d", filterValue, iterations);
    
    for (int i=0; i<iterations; i++) {
        float randomSeed = rand() / (float)RAND_MAX;
        //NSLog(@"%d: %f", i, randomSeed);
        currentData = [self glitchJpegBytesWithData:currentData WithHeaderSize:headerSize WithSeed:randomSeed amount:0.5 i:i len:iterations];
    }

    filteredImage = [UIImage imageWithData:currentData];
    if (filteredImage == nil) {
        [self setFilterValue:filterValue];
    }
    [self updateDelegateWithImage:filteredImage];
}

- (UIImage*)filteredImage
{
    return filteredImage;
}

- (NSData*) glitchJpegBytesWithData:(NSData*)jpegGlitchData WithHeaderSize:(int)jpegHeaderSize WithSeed:(float)seed amount:(float)amount i:(int)i len:(int)len
{
    
    int max_index = (int)(jpegGlitchData.length - headerSize - 4);
    double px_min = max_index / len * i;
    double px_max = max_index / len * ( i + 1 );
    
    int delta = px_max - px_min;
    int px_i = px_min + floorf(delta * seed);
    
    if ( px_i > max_index )
    {
        px_i = max_index;
    }
    
    int index = headerSize + px_i ;
    
    Byte *byte_array = (Byte*)malloc([jpegData length]);
    memcpy(byte_array, [jpegGlitchData bytes], [jpegGlitchData length]);
    byte_array[index] = floor( amount * 256 );

    NSData *newImage = [NSData dataWithBytes:byte_array length:[jpegGlitchData length]];
    free(byte_array);
    return newImage;
}

- (void)handleTap:(UITapGestureRecognizer*)gestureRecognizer
{
    [self seedWith:time(NULL)];
    [self setFilterValue:self.filterValue];
}

- (void)setFilterSettings:(NSDictionary *)filterSettings
{
    [super setFilterSettings:filterSettings];
    if (filterSettings == nil)
        return;
    
    if ([filterSettings objectForKey:@"seed"]) {
        NSNumber *seedValue = [filterSettings objectForKey:@"seed"];
        [self seedWith:[seedValue longValue]];
    }
    
    if ([filterSettings objectForKey:@"quality"]) {
        NSNumber *seedValue = [filterSettings objectForKey:@"quality"];
        [self setQuality:[seedValue floatValue]];
    }
}

- (NSDictionary*)filterSettings
{
    NSMutableDictionary *settings = [[super filterSettings] mutableCopy];
    if (settings == nil) {
        settings = [NSMutableDictionary dictionary];
    }
    
    [settings setObject:[NSNumber numberWithLong:_seed] forKey:@"seed"];
    [settings setObject:[NSNumber numberWithFloat:self.jpegQuality] forKey:@"quality"];

    return settings;
}

- (void)randomizeSettings
{
    [self seedWith:time(NULL)];
}

@end
