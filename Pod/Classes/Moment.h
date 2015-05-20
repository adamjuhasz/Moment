//
//  Moment.h
//  feeder
//
//  Created by Adam Juhasz on 7/22/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//UICKeyChainStore

#import <Foundation/Foundation.h>
#import "MomentFilter.h"
#import <CoreLocation/CoreLocation.h>
#import "SecureMTLModel.h"

#define kMomentFilterUpdated @"MomentFilterUpdatedNotification"

@class Moment;

@protocol MomentDelegate <NSObject>
@required
- (void)momenthasloadedImage:(Moment*)moment;
- (void)moment:(Moment*)moment downloadProgress:(float)progress;
- (void)momentHasErrored:(Moment*)moment;

@end

@interface Moment : SecureMTLModel <MTLJSONSerializing, MomentFilterDelegate>
{
    UIImage *_image;
    NSString *_filterName;
    NSMutableArray *delegates;
    NSDictionary *_filterSettings;
}

- (id)init;

//moment properties
@property NSString *postid;
@property NSUInteger lifetime;
@property double expires;
@property NSString *filterName;
@property NSTimeInterval dateCreated;
@property NSString *userid;
@property NSString *text;
@property UIImage *image;
@property NSDictionary *filterSettings;

@property NSUInteger likeCount;
@property NSUInteger commentCount;
@property NSUInteger activityCount;
@property NSTimeInterval lastChanged;

@property BOOL isPrivate;
@property CLLocation *coordinates;
@property (readonly) NSString *key;

@property NSMutableArray *likes;
@property NSMutableArray *hashtags;
@property BOOL erroredOut;

//generated
@property (readonly) NSDictionary *dictionary;
@property (readonly) NSTimeInterval lifetimeLeft;

//app based
@property float downloadPercent;
@property BOOL imageLoaded;

@property (readonly) UIImage *filteredImage;
@property MomentFilter *filter;

//operate on this moment

- (void)addDelegate:(id<MomentDelegate>)deleage;
- (void)removeDelegate:(id)delegate;
- (void)startTimer;

@end
