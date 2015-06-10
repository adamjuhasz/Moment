//
//  MomentView.m
//  Pods
//
//  Created by Adam Juhasz on 5/27/15.
//
//

#import "MomentView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MomentView () <MomentFilterDelegate>
{
    UIImageView *imageView;
    MomentFilter *copyOfFilter;
    NSTimer *longPressTimer;
    UILongPressGestureRecognizer *longPresser;
    RACDisposable *previousSubscription;
}
@end

@implementation MomentView

- (void)commonInit
{
    imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    longPresser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdingDownWith:)];
    [imageView addGestureRecognizer:longPresser];
    self.userInteractionEnabled = YES;
    imageView.userInteractionEnabled = YES;
    
    [[RACObserve(self, moment)
        filter:^BOOL(id value) {
            return (value != nil);
    }]
        subscribeNext:^(Moment *aMoment) {
            [previousSubscription dispose];
            previousSubscription = [[RACObserve(aMoment, filteredImage)
                                       filter:^BOOL(id value) {
                                            return (value != nil);
                                    }] subscribeNext:^(UIImage *filteredImage) {
                                            imageView.image = filteredImage;
                                    }];
    }];
    
    [self rac_liftSelector:@selector(setLongPressEnabled:) withSignals:RACObserve(self, touchEnabled), nil];
    self.touchEnabled = YES;
}

- (void)setLongPressEnabled:(NSNumber*)isEnabled
{
    longPresser.enabled = [isEnabled boolValue];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    imageView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)holdingDownWith:(UILongPressGestureRecognizer*)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            copyOfFilter = [self.moment.filter copy];
            copyOfFilter.filterValue = self.moment.filter.filterValue;
            copyOfFilter.delegate = self;
            
            longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerWithValuesDown:) userInfo:nil repeats:YES];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [longPressTimer invalidate];
            longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerWithValueUp:) userInfo:nil repeats:YES];
            break;
            
        default:
            break;
    }
}

- (void)timerWithValuesDown:(NSTimer*)timer;
{
    if (copyOfFilter.filterValue == 0) {
        [longPressTimer invalidate];
    } else {
        copyOfFilter.filterValue -= 0.01;
    }
}

- (void)timerWithValueUp:(NSTimer*)timer;
{
    if (copyOfFilter.filterValue >= self.moment.filter.filterValue) {
        [longPressTimer invalidate];
        copyOfFilter = nil;
    } else {
        copyOfFilter.filterValue += 0.01;
    }
}

- (void)momentFilter:(MomentFilter *)filter hasNewFilteredImage:(UIImage *)image
{
    imageView.image = image;
}

@end
