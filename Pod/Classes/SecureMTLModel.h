//
//  SecureMTLModel.h
//  moments
//
//  Created by Adam Juhasz on 10/20/14.
//  Copyright (c) 2014 Adam Juhasz. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface SecureMTLModel : MTLModel <NSCoding, MTLJSONSerializing>

@end
