//
//  MomentView.h
//  Pods
//
//  Created by Adam Juhasz on 5/27/15.
//
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface MomentView : UIView

@property Moment *moment;
@property BOOL touchEnabled;

- (void)commonInit;
- (void)updatedMomentTo:(Moment*)aMoment;

@end
