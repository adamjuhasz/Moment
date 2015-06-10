//
//  EditableMomentView.m
//  Pods
//
//  Created by Adam Juhasz on 5/28/15.
//
//

#import "EditableMomentView.h"
#import "MomentView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIImage+Resizing.h"

@interface EditableMomentView () <UIScrollViewDelegate>
{
    UIImageView *internalMomentView;
    UIScrollView *scrollView;
    MomentView *momentView;
    NSTimer *momentTimer;
    RACSignal *imageReactiveSignal;
    RACSignal *momentReactiveSignal;
}

@end

@implementation EditableMomentView

- (void)commonInit
{
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    momentView = [[MomentView alloc] initWithFrame:self.bounds];
    [self insertSubview:momentView belowSubview:scrollView];
    momentView.hidden = YES;
    
    momentReactiveSignal = [self rac_liftSelector:@selector(setWithMoment:) withSignals:RACObserve(self, moment), nil];
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

- (void)layoutSubviews
{
    scrollView.frame = self.bounds;
    [super layoutSubviews];
}

- (void)setWithMoment:(Moment*)moment
{
    if (moment == nil) {
        return;
    }
    
    NSError *error;
    self.editedMoment = [[Moment alloc] initWithDictionary:moment.dictionary error:&error];
    self.editedMoment.dateExpires = [NSDate distantFuture];
    momentView.moment = self.editedMoment;
    
    imageReactiveSignal = [self rac_liftSelector:@selector(setWithImage:) withSignals:RACObserve(moment, image), nil];
}

- (void)setWithImage:(UIImage*)image
{
    if (image == nil)
        return;
    
    self.editedMoment.image = [image scaleToSize:momentView.bounds.size];
    self.croppedImage = image;
    
    CGFloat zoom;
    CGPoint offset;
    
    if (image.size.width > image.size.height) {
        zoom = scrollView.bounds.size.width/image.size.height;
        offset.x = (zoom*image.size.width-scrollView.bounds.size.width)/2.0;
        offset.y = 0;
    } else {
        zoom = scrollView.bounds.size.width/image.size.width;
        offset.x = 0;
        offset.y = (zoom*image.size.height-scrollView.bounds.size.width)/2.0;
    }
    
    [internalMomentView removeFromSuperview];
    internalMomentView = [[UIImageView alloc] initWithImage:image];
    [scrollView addSubview:internalMomentView];
    
    scrollView.contentSize = CGSizeMake(image.size.width, image.size.height);
    
    scrollView.minimumZoomScale = zoom;
    scrollView.maximumZoomScale = 1.0;
    scrollView.zoomScale = zoom;
    scrollView.contentOffset = offset;

}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //NSLog(@"internalMomentView frame: %@", NSStringFromCGRect(internalMomentView.frame));
    return internalMomentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //NSLog(@"zoom at %f", scale);
    [self cropCenter];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [self cropCenter];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cropCenter];
}

- (void)cropCenter
{
    CGRect frame;
    
    frame.origin.x = scrollView.contentOffset.x / scrollView.zoomScale;
    frame.origin.y = scrollView.contentOffset.y / scrollView.zoomScale;
    frame.size.width = self.bounds.size.width / scrollView.zoomScale;
    frame.size.height = self.bounds.size.width / scrollView.zoomScale;
    
    self.croppedImage = [self getSubImageFrom:self.moment.image WithRect:frame];
    self.editedMoment.image = [self.croppedImage scaleToSize:momentView.bounds.size];
}

- (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

- (void)startLoopingMoment
{
    momentView.hidden = NO;
    momentView.moment.filteredImage = nil;
    momentView.moment.filter.filterValue = 0.0;
    [self bringSubviewToFront:momentView];
    
    momentTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateTimers) userInfo:nil repeats:YES];
}

- (void)stopLoopingMoment
{
    [momentTimer invalidate];
    momentView.hidden = YES;
    [self bringSubviewToFront:scrollView];
}

- (void)updateTimers
{
    if (momentView.moment.filter.filterValue >= 1.0) {
        momentView.moment.filter.filterValue = 0.0;
    } else {
        momentView.moment.filter.filterValue += 0.01;
    }
}

@end
