//
//  MomentLightleakFilter.m
//  Moments
//
//  Created by Adam Juhasz on 9/27/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentLightleakFilter.h"
#import <NYXImagesKit/UIImage+Resizing.h>
#import <NYXImagesKit/UIImage+Filtering.h>
#import <GPUImage/GPUImage.h>

static NSArray *imageNames;
static NSMutableDictionary *loadedFiles;
static BOOL filesLoaded = NO;
static BOOL filesLoading = NO;

@interface MomentLightleakFilter ()
{
    CIFilter *filter;
    CIImage *myImage;
    UIImage *lightLeak;
    CIContext *context;
    UIImage *screen;
    long _seed;
    NSMutableArray *leaks;
    BOOL loadedLeaks;
}
@end

@implementation MomentLightleakFilter

+ (void)loadLeaks
{
    if (filesLoading) {
        return;
    }
    
    if (!imageNames) {
        imageNames = @[@"Moment.bundle/1.jpg", @"Moment.bundle/2.jpg", @"Moment.bundle/3.jpg", @"Moment.bundle/4.jpg", @"Moment.bundle/5.jpg"];
    }
    if (!loadedFiles) {
        loadedFiles = [NSMutableDictionary dictionary];
    }
    
    filesLoading = YES;
    
    for(NSString *name in imageNames) {
        UIImage *image = [UIImage imageNamed:name];
        [loadedFiles setObject:image forKey:name];
        //NSLog(@"loaded %@ into dictionary", name);
    }
    filesLoaded = YES;
}

- (id) init
{
    self = [super init];
    if (self) {
        loadedLeaks = NO;
        context = [CIContext contextWithOptions:nil]; //@{kCIContextUseSoftwareRenderer : @(YES)}];
        filter = [CIFilter filterWithName:@"CIScreenBlendMode"];
        leaks = [NSMutableArray array];
        [[self class] loadLeaks];
        [self loadArrayOfFiled:@[@"Moment.bundle/1.jpg"]];
    }
    return self;
}

- (void)randomizeSettings
{
    leaks = [NSMutableArray array];
    //reset seed
    srand48(time(NULL));
    NSInteger imageCountChance = floor(drand48() * ((100)-1));
    NSUInteger imageCount = 1;
    if (0 < imageCountChance && imageCountChance < 50 ) {
        imageCount = 1;
    } else if (51 < imageCountChance && imageCountChance < 80 ) {
        imageCount = 2;
    } else if (81 < imageCountChance && imageCountChance < 90 ) {
        imageCount = 3;
    } else if (91 < imageCountChance && imageCountChance < 100 ) {
        imageCount = 4;
    }
    
    for(int i=0; i< imageCount; i++) {
        NSInteger choice = floor(drand48() * ((5)-1))+1;
        //NSLog(@"random choice: %ld", (long)choice);
        NSString *imageName = [imageNames objectAtIndex:choice];
        [leaks addObject:imageName];
    }
    

    [self loadArrayOfFiled:leaks];
#if TARGET_IPHONE_SIMULATOR
    //scale it back up because set image will scale it down
    image = [image scaleByFactor:2.0];
#endif
    [self setWithUIImage:image];
    self.filterValue = self.filterValue;
}

- (void)loadArrayOfFiled:(NSArray*)array;
{
    if (array.count == 0 || array == nil) {
        array = @[imageNames[0]];
    }
    
    NSMutableString *fileid = [NSMutableString stringWithFormat:@""];
    for(int i=0; i< array.count; i++) {
        NSString *imageName = [array objectAtIndex:i];
        [fileid appendString:imageName];
    }
    
    if ([loadedFiles objectForKey:fileid]) {
        screen = [loadedFiles objectForKey:fileid];
        loadedLeaks = YES;
        return;
    }

    NSLog(@"loading %@ files", array);
    
    screen = [loadedFiles objectForKey:[array objectAtIndex:0]];
    
    for(int i=1; i<array.count; i++) {
        NSString *imageName = [array objectAtIndex:i];
        UIImage *newImage = [loadedFiles objectForKey:imageName];
        
        if (newImage != nil) {
            GPUImageScreenBlendFilter *screenFilter = [[GPUImageScreenBlendFilter alloc] init];
            GPUImagePicture *firstLayer = [[GPUImagePicture alloc] initWithImage:screen];
            GPUImagePicture *nextLayer = [[GPUImagePicture alloc] initWithImage:newImage];
            [firstLayer addTarget:screenFilter atTextureLocation:0];
            [nextLayer addTarget:screenFilter atTextureLocation:1];
            
            [screenFilter useNextFrameForImageCapture];
            [firstLayer processImage];
            [nextLayer processImage];
            
            screen = [screenFilter imageFromCurrentFramebuffer];
            //NSLog(@"loaded %@", imageName);
        }
    }
    
    loadedLeaks = YES;
    [loadedFiles setObject:screen forKey:fileid];
    //NSLog(@"saved %@", fileid);
}

- (void)setWithUIImage:(UIImage *)anImage;
{
#if TARGET_IPHONE_SIMULATOR
    anImage = [anImage scaleByFactor:0.5];
#endif
    
    [super setWithUIImage:anImage];
    if (anImage.CIImage) {
        myImage = anImage.CIImage;
    } else {
        myImage = [CIImage imageWithCGImage:anImage.CGImage];
    }
    
    lightLeak = [screen scaleToSize:anImage.size usingMode:NYXResizeModeAspectFill];
    [filter setValue:myImage forKey:kCIInputBackgroundImageKey];
    CIImage *light = [CIImage imageWithCGImage:lightLeak.CGImage];
    [filter setValue:light forKey:kCIInputImageKey];
}

- (void)setFilterValue:(float)filterValue
{
    [super setFilterValue:filterValue];
 
    CIImage *light = [CIImage imageWithCGImage:[lightLeak opacity:filterValue].CGImage];
    [filter setValue:light forKey:kCIInputImageKey];

    UIImage *filtered = [self filteredImage];
    [self updateDelegateWithImage:filtered];
}

- (UIImage*)filteredImage
{
    if (_cachedImage) {
        return _cachedImage;
    }
    
    CIImage *output = [filter outputImage];
    CGImageRef cgimg =  [context createCGImage:output fromRect:[output extent]];
    UIImage *outputImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return outputImage;
}

- (void)setFilterSettings:(NSDictionary *)filterSettings
{
    [super setFilterSettings:filterSettings];
    if ([filterSettings objectForKey:@"files"]) {
        leaks = [filterSettings objectForKey:@"files"];
        [self loadArrayOfFiled:leaks];
    }
}

- (NSDictionary*)filterSettings
{
    NSMutableDictionary *settings = [[super filterSettings] mutableCopy];
    if (settings == nil) {
        settings = [NSMutableDictionary dictionary];
    }
    [settings setObject:leaks forKey:@"files"];
    return settings;
}

@end
