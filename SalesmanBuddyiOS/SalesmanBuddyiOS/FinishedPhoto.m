//
//  FinishedPhoto.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "FinishedPhoto.h"

@implementation FinishedPhoto

+(instancetype)objectFromDictionary:(NSDictionary *)dictionary{
    return [[FinishedPhoto alloc] initWithDictionary:dictionary];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.filename = dictionary[@"filename"];
        self.bucketId = [dictionary[@"bucketId"] integerValue];
    }
    return self;
}

+(NSDictionary *)dictionaryFromFinishedPhoto:(FinishedPhoto *)finishedPhoto{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:@(finishedPhoto.bucketId) forKey:@"bucketId"];
    [d setValue:finishedPhoto.filename forKey:@"filename"];
    return d;
}

@end
