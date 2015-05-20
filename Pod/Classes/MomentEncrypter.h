//
//  MomentEncrypter.h
//  moments
//
//  Created by Adam Juhasz on 10/22/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MomentEncrypter : NSValueTransformer

@property NSData *key;
@property NSData *iv;

- (void)setKeyAndIVWith:(NSString*)password;

@end
