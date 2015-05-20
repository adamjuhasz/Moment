//
//  MomentEncrypter.m
//  moments
//
//  Created by Adam Juhasz on 10/22/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import "MomentEncrypter.h"
#import <CocoaSecurity/CocoaSecurity.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

@implementation MomentEncrypter

+ (void)initialize
{
    NSString *encryptionString = [UICKeyChainStore stringForKey:@"encryptionString"];
    if (encryptionString == nil) {
        //generate one
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSString *time = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        NSString *deviceName = [[UIDevice currentDevice] name];
        NSString *combined = [NSString stringWithFormat:@"%@-%@-%@", bundleID, time, deviceName];
        [UICKeyChainStore setString:combined forKey:@"encryptionString"];
    }
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

+ (Class)transformedValueClass
{
    return NSData.class;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *encryptionString = [UICKeyChainStore stringForKey:@"encryptionString"];
        [self setKeyAndIVWith:encryptionString];
    }
    return self;
}

- (id)transformedValue:(id)dataIn
{
    //encrypt string
    CocoaSecurityResult *encrypted = [CocoaSecurity aesEncryptWithData:dataIn key:self.key iv:self.iv];
    NSData *enctypedData = encrypted.data;
    
    return enctypedData;
}

- (id)reverseTransformedValue:(id)dataIn
{
    CocoaSecurityResult *decryptedResult = [CocoaSecurity aesDecryptWithData:dataIn key:self.key iv:self.iv];
    NSData *decryptedData = decryptedResult.data;
    
    return decryptedData;
}

- (void)setKeyAndIVWith:(NSString *)password
{
    CocoaSecurityResult *keyIV = [CocoaSecurity sha384:password];
    self.key = [keyIV.data subdataWithRange:NSMakeRange(0, 32)];
    self.iv = [keyIV.data subdataWithRange:NSMakeRange(32, 16)];
}



@end
