//
//  Moment.m
//  feeder
//
//  Created by Adam Juhasz on 7/22/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "Moment.h"
#import "ListOfMomentFilters.h"
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/MTLValueTransformer.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

static const int ddLogLevel = DDLogLevelInfo;

@interface Moment () <MomentFilterDelegate>
{
    NSDictionary *myDictionary;
    NSTimer *filterUpdateTimer;
    void * GUARD_LifetimeChanged;
    void * GUARD_CreationDateChanged;
    void * GUARD_ErroredOut;
}

@property BOOL needsUpdate;

@end

@implementation Moment

- (void)commonInit
{
    //set up scaffolding
    delegates = [NSMutableArray array];
    
    //set sane defaults
    if (GUARD_LifetimeChanged == NULL) {
        GUARD_LifetimeChanged = &GUARD_LifetimeChanged;
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(lifetime)) options:0 context:GUARD_LifetimeChanged];
    }
    
    if (GUARD_CreationDateChanged == NULL) {
        GUARD_CreationDateChanged = &GUARD_CreationDateChanged;
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(dateCreated)) options:0 context:GUARD_CreationDateChanged];
    }
    if (GUARD_ErroredOut == NULL) {
        GUARD_ErroredOut = &GUARD_ErroredOut;
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(erroredOut)) options:0 context:GUARD_ErroredOut];
    }
    
    _imageLoaded = NO;
    _downloadPercent = 0.0;
    _erroredOut = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
        _dateCreated = [[NSDate date] timeIntervalSince1970];
        _lifetime = 60*60*24;
        _expires = _dateCreated + _lifetime;
    }
    return  self;
}

- (id)initWithDictionary:(NSDictionary *)post error:(NSError *__autoreleasing *)error
{
    self = [super initWithDictionary:post error:error];
    if (self) {
        [self commonInit];
        
        //internal conistency checks
        if ([self validateMonent] == NO) {
            return nil;
        }
        
        _likes = [_likes mutableCopy];
        _hashtags = [_hashtags mutableCopy];
        
        myDictionary = [post copy];
    }
    return self;
}

- (BOOL)validateMonent
{
    NSTimeInterval calculatedExpiration = self.dateCreated + self.lifetime;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if (ABS(calculatedExpiration - self.expires) > 60) {
        DDLogError(@"%@(0x%08X) Moment's expiration dates are out of sync calculated: %f, loaded: %f, created:%f, lifetime: %lu", self.postid,  (unsigned int)self, calculatedExpiration, self.expires, self.dateCreated, (unsigned long)self.lifetime);
        return NO;
    }
    if (self.expires < currentTime) {
        DDLogInfo(@"%@(0x%08X) Moment's is expired", self.postid,  (unsigned int)self);
        return NO;
    }
    
    return YES;
}

#pragma mark - Scafolding

- (void)dealloc
{
    if (filterUpdateTimer) {
        [filterUpdateTimer invalidate];
        filterUpdateTimer = nil;
    }
    
    if (GUARD_LifetimeChanged == &GUARD_LifetimeChanged) {
        GUARD_LifetimeChanged = NULL;
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(lifetime))];
    }
    if (GUARD_CreationDateChanged == &GUARD_CreationDateChanged) {
        GUARD_CreationDateChanged = NULL;
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(dateCreated))];
    }
    if (GUARD_ErroredOut == &GUARD_ErroredOut) {
        GUARD_ErroredOut = NULL;
        [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(erroredOut))];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == GUARD_LifetimeChanged || context == GUARD_CreationDateChanged) {
        self.expires = self.lifetime + self.dateCreated;
    } else if (context == GUARD_ErroredOut) {
        @synchronized(delegates) {
            for (id <MomentDelegate> delagate in delegates) {
                [delagate momentHasErrored:self];
            }
        }
    }
}

- (NSString*)description
{
    NSString *introString = @"";
    if ([super class] == [NSObject class]) {
        introString = [NSString stringWithFormat:@"<Moment 0x%08X>", (unsigned)self];
    } else {
        introString = [NSString stringWithFormat:@"%@;", [super description]];
    }
    return [NSString stringWithFormat:@"%@ postid: %@; date: %f; lifetime: %lu; time to live: %f; filter value: %f; filter: %@; timer: %f",
            introString,
            self.postid,
            self.dateCreated,
            (unsigned long)self.lifetime,
            self.lifetimeLeft,
            self.filter.filterValue,
            self.filterName,
            filterUpdateTimer.timeInterval];
}

#pragma mark - Generated Values

- (NSTimeInterval)lifetimeLeft
{
    NSTimeInterval lifeLeft = _expires - [[NSDate date] timeIntervalSince1970];
    return lifeLeft;
}

- (BOOL)isValid
{
    if (self.postid == nil) {
        return NO;
    }
    
    return YES;
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey
{
    //object property : JSON property
    return @{
         NSStringFromSelector(@selector(postid)) : @"postid",
         NSStringFromSelector(@selector(location)) : @"location",
         NSStringFromSelector(@selector(lifetime)) : @"lifetime",
         NSStringFromSelector(@selector(expires)) : @"expiresAfter",
         NSStringFromSelector(@selector(filterName)) : @"filter",
         NSStringFromSelector(@selector(dateCreated)) : @"date",
         NSStringFromSelector(@selector(userid)) : @"userid",
         NSStringFromSelector(@selector(text)) : @"text",
         NSStringFromSelector(@selector(likeCount)) : @"likes",
         NSStringFromSelector(@selector(commentCount)) : @"commnets",
         NSStringFromSelector(@selector(activityCount)) : @"activity",
         NSStringFromSelector(@selector(lastChanged)) : @"lastChanged",
         NSStringFromSelector(@selector(isPrivate)) : @"private",
         NSStringFromSelector(@selector(filterSettings)) : @"filterSettings",
         NSStringFromSelector(@selector(dictionary)) : NSNull.null,
         NSStringFromSelector(@selector(downloadPercent)) : NSNull.null,
         NSStringFromSelector(@selector(imageLoaded)) : NSNull.null,
         NSStringFromSelector(@selector(filteredImage)) : NSNull.null,
         NSStringFromSelector(@selector(filter)) : NSNull.null,
         NSStringFromSelector(@selector(coordinates)) : NSNull.null,
         NSStringFromSelector(@selector(image)) : NSNull.null,
         NSStringFromSelector(@selector(key)) : NSNull.null,
         NSStringFromSelector(@selector(likes)) : @"likeArray",
         NSStringFromSelector(@selector(hashtags)) : @"hashtags",
         NSStringFromSelector(@selector(erroredOut)) : NSNull.null
    };
}

+ (NSValueTransformer *)locationJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (void)mergeValuesForKeysFromModel:(Moment *)newerModel
{
    if (newerModel.activityCount > self.activityCount) {
        [super mergeValuesForKeysFromModel:newerModel];
    } else if (newerModel.activityCount == self.activityCount && newerModel.lastChanged > self.lastChanged) {
        [super mergeValuesForKeysFromModel:newerModel];
    }
}

- (NSDictionary*)dictionary
{
    if ([self isValid] == NO) {
        return nil;
    }
    
    NSError *error;
    NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    if (!error)
        return dict;
    else {
        DDLogError(@"Error making dictionary: %@", error);
        return nil;
    }
}

- (NSString*)key
{
    return self.postid;
}

- (BOOL)isEqual:(Moment*)otherMoment
{
    if ([otherMoment isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    if ([self.postid isEqualToString:otherMoment.postid]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Image

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageLoaded = YES;
    self.downloadPercent = 1.0;
    
    if (self.filter == nil) {
        DDLogInfo(@"%@ has no filter to load image into", self.postid);
    }
    [self.filter setWithUIImage:_image];
    [self updateFilter];
    
    @synchronized(delegates) {
        for (id <MomentDelegate> delagate in delegates) {
            [delagate momenthasloadedImage:self];
        }
    }
}

- (UIImage*)image
{
    return _image;
}

- (void)setFilteredImage:(UIImage *)filteredImage
{
    //_filteredImage = filteredImage;
}

- (UIImage*)filteredImage
{
    UIImage *filteredImage = nil;
    
    if (self.filter) {
        filteredImage = self.filter.filteredImage;
        
        //let them know
        if (self.imageLoaded == NO) {
            self.imageLoaded = YES;
        }
    }
    return filteredImage;
}

#pragma mark - Filter

- (void)setFilterName:(NSString *)filterName
{
    _filterName = filterName;
    [self loadFilter];
}

- (NSString*)filterName
{
    return _filterName;
}

- (void)setFilterSettings:(NSDictionary *)filterSettings
{
    _filterSettings = filterSettings;
}

- (NSDictionary*)filterSettings
{
    return self.filter.filterSettings;
}

- (void) loadFilter
{
    //if we have a timer for the previous filter, kill it
    if (filterUpdateTimer) {
        [filterUpdateTimer invalidate];
        filterUpdateTimer = nil;
    }
    
    //NSLog(@"%@ is loading filter %@", self.postid, self.filterName);
    //create filter
    self.filter = [MomentFilter filterWithName:self.filterName];
    self.filter.filterSettings = _filterSettings;
    
    //start running filter
    if (self.filter) {
        UIImage *loadedImage = self.image;
        if (loadedImage) {
            [self.filter setWithUIImage:loadedImage];
        }
        self.filter.delegate = self;
        [self updateFilter];
        
        //set timer to auto-update filter
        [self startTimer];
    }
}

- (void)startTimer
{
    [filterUpdateTimer invalidate];
    filterUpdateTimer = nil;
    
    NSTimeInterval SecondsBetweenUpdates = (float)self.lifetime/self.filter.filterSteps;
    DDLogInfo(@"Setting timer to fire every %f seconds", SecondsBetweenUpdates);
    filterUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:SecondsBetweenUpdates
                                                         target:self
                                                       selector:@selector(updateFilter)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)backFromBackground
{
    if (self.needsUpdate == YES) {
        self.needsUpdate = NO;
        [self updateFilter];
    }
}

- (void)updateFilter
{
    UIApplicationState currentAppState = [[UIApplication sharedApplication] applicationState];
    if (currentAppState != UIApplicationStateActive) {
        //don't update
        self.needsUpdate = YES;
        return;
    }
    
    //find current filter percent
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    double secondsOfLifeRemaining = self.expires - currentTime;
    double percentToFilter = 1.0;
    if (secondsOfLifeRemaining > 0) {
        percentToFilter = (self.lifetime - secondsOfLifeRemaining)/(double)self.lifetime;
    } else {
        DDLogInfo(@"Moment %@ seems to be filtering after expiration", self.postid);
        [filterUpdateTimer invalidate];
        filterUpdateTimer = nil;
    }
    percentToFilter = roundf(percentToFilter*100)/100.0;
    
    percentToFilter = MIN(1.0, percentToFilter);
    percentToFilter = MAX(0.0, percentToFilter);
    
    self.filter.filterValue = percentToFilter;
    
    DDLogDebug(@"updateFilter %@", self);
}

#pragma mark - Moment Delegate

- (void)addDelegate:(id<MomentDelegate>)deleage
{
    @synchronized(delegates) {
        [delegates addObject:deleage];
    }
}

- (void)removeDelegate:(id)delegate
{
    @synchronized(delegates) {
        [delegates removeObject:delegate];
    }
}

#pragma mark - MomentFilter Delegate

- (void)momentFilter:(MomentFilter*)filter hasNewFilteredImage:(UIImage*)image
{
    //NSLog(@"%@(0x%08X) has a new filtered image", self.postid, (unsigned int)self);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kMomentFilterUpdated object:self userInfo:nil];
    });
}

@end
