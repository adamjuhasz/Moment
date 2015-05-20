//
//  MomentFilter.h
//  MomentImage
//
//  Created by Adam Juhasz on 7/29/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MomentFilter;

@protocol MomentFilterDelegate <NSObject>
@required
- (void)momentFilter:(MomentFilter*)filter hasNewFilteredImage:(UIImage*)image;

@end

@interface MomentFilter : NSObject
{
    float _filterValue;
    UIImage *image;
    UIImage *_cachedImage;
    
    id <MomentFilterDelegate> _delegate;
}

@property float filterValue;
@property id <MomentFilterDelegate> delegate;
@property NSUInteger filterSteps;
@property NSString *filterName;
@property NSDictionary *filterSettings;

- (void)setWithUIImage:(UIImage*)image;
- (UIImage*)filteredImage;
- (void)randomizeSettings;
- (void)updateDelegateWithImage:(UIImage*)image;

+ (MomentFilter*)filterWithName:(NSString*)string;

@end
