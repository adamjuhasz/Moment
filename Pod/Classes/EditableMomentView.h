//
//  EditableMomentView.h
//  Pods
//
//  Created by Adam Juhasz on 5/28/15.
//
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface EditableMomentView : UIView

@property Moment *moment;
@property Moment *editedMoment;
@property UIImage *croppedImage;

- (void)startLoopingMoment;
- (void)stopLoopingMoment;

@end
