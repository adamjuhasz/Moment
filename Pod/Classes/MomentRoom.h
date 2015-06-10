//
//  MomentRoom.h
//  Pods
//
//  Created by Adam Juhasz on 5/21/15.
//
//

#import <Foundation/Foundation.h>
//#import "Moment.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveTableViewBinding/CEObservableMutableArray.h>

@interface MomentRoom : NSObject

@property NSString *roomid;
@property NSString *roomName;
@property UIColor *backgroundColor;
@property UIImage *backgroundImage;
@property CGFloat roomLifetime;

@property CEObservableMutableArray *moments;

- (void)addMoments:(NSArray*)moments;

@end