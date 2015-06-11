//
//  MomentRoom.m
//  Pods
//
//  Created by Adam Juhasz on 5/21/15.
//
//

#import "MomentRoom.h"
#import "Moment.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MomentRoom ()

@end

@implementation MomentRoom

- (id)init
{
    self = [super init];
    if (self) {
        _moments = [[CEObservableMutableArray alloc] init];
        self.allowsPosting = YES;
    }
    return self;
}

- (void)addMoments:(NSArray*)moments
{
    NSMutableArray *newMoments = [NSMutableArray array];
    for (Moment *aMoment in moments) {
        BOOL momentIsNew = YES;
        for (Moment *anExistingMoment in _moments) {
            if ([aMoment.postid isEqualToString:anExistingMoment.postid]) {
                momentIsNew = NO;
                break;
            }
        }
        if (momentIsNew) {
            [newMoments addObject:aMoment];
        }
    }
    
    if (newMoments.count > 0) {
        [_moments addObjectsFromArray:newMoments];
        [_moments sortUsingComparator:^NSComparisonResult(Moment *obj1, Moment *obj2) {
            return [obj2.dateCreated compare:obj1.dateCreated];
        }];
    }
}

@end
