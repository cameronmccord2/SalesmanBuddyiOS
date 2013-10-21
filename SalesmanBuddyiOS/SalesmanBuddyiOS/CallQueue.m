//
//  CallQueue.m
//  Item Mapper
//
//  Created by Cameron McCord on 8/23/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "CallQueue.h"

@implementation CallQueue


-(id)initQueueItem:(NSMutableURLRequest *)newRequest type:(NSNumber *)newType body:(NSDictionary *)newBody delegate:(id)newDelegate{
    self = [super init];
    if (self) {
        self.request = newRequest;
        self.delegate = newDelegate;
        self.alreadySent = NO;
        self.type = newType;
        self.body = newBody;
    }
    return self;
}
@end
