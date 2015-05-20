//
//  UrlMoment.h
//  Pods
//
//  Created by Adam Juhasz on 5/20/15.
//
//

#import "Moment.h"

@interface UrlMoment : Moment

@property NSURL *location;
- (void)downloadMomentsImage;

@end
