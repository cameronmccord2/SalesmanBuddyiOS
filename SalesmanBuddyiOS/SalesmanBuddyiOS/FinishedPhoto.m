//
//  FinishedPhoto.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "FinishedPhoto.h"

@implementation FinishedPhoto

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.filename = dictionary[@"filename"];
        self.bucketId = [dictionary[@"bucketId"] integerValue];
    }
    return self;
}

@end
