//
//  MomentGlitchFilter.h
//  MomentImage
//
//  Created by Adam Juhasz on 7/29/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentFilter.h"

@interface MomentGlitchFilter : MomentFilter

@property float jpegQuality;
- (void)seedWith:(long)seed;

@end
