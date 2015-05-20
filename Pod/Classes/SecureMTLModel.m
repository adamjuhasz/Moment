//
//  SecureMTLModel.m
//  moments
//
//  Created by Adam Juhasz on 10/20/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "SecureMTLModel.h"
#import "MomentEncrypter.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const int ddLogLevel = DDLogLevelDebug;

@implementation SecureMTLModel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSData *encrypted = [aDecoder decodeObjectForKey:@"encryptedJSON"];
    MomentEncrypter *transformer = [[MomentEncrypter alloc] init];
    NSData *decryptedData = [transformer reverseTransformedValue:encrypted];
    if (decryptedData == nil) {
        DDLogError(@"couldn't decrypt data");
        return nil;
    }
    
    NSError *jsonError;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&jsonError];
    if (jsonError || !dict) {
        DDLogError(@"couldn't convert data to JSON object: %@", jsonError);
        return nil;
    }
    
    NSError *mantleError;
    Class class = self.class;
    id object = [MTLJSONAdapter modelOfClass:class fromJSONDictionary:dict error:&mantleError];
    if (mantleError || !object) {
        DDLogError(@"couldn't covert dict to mantle object: %@", mantleError);
        return nil;
    }
    
    return object;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //grab JSON of self
    NSError *error;
    NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    if (!dictionary) {
        DDLogError(@"ERROR; couldn't convert moment to dictionary, %@", error);
        return;
    }
    
    NSError *jsonError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&jsonError];
    if (jsonError || !data) {
        DDLogError(@"couldn't get string from JSON, %@", jsonError);
        return;
    }
    
    //encrypt string
    MomentEncrypter *transformer = [[MomentEncrypter alloc] init];
    NSData *enctypedData = [transformer transformedValue:data];
    
    [aCoder encodeObject:enctypedData forKey:@"encryptedJSON"];
}

+ (NSDictionary*)JSONKeyPathsByPropertyKey
{
    return @{};
}
@end
