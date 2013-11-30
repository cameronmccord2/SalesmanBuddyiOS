//
//  CallQueue.m
//  Item Mapper
//
//  Created by Cameron McCord on 8/23/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "CallQueue.h"

@implementation CallQueue


-(id)initQueueItem:(NSMutableURLRequest *)newRequest body:(NSDictionary *)newBody delegate:(id)newDelegate{
    self = [super init];
    if (self) {
        self.request = newRequest;
        self.delegate = newDelegate;
        self.alreadySent = NO;
        self.body = newBody;
    }
    return self;
}

+(instancetype)initWithRequest:(NSMutableURLRequest *)request body:(NSDictionary *)body delegate:(id)delegate success:(void (^)(NSData *, void (^)()))success error:(void (^)(NSData *, NSError *, void (^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress{
    CallQueue *item = [[CallQueue alloc] init];
    item.request = request;
    item.body = body;
    item.delegate = delegate;
    item.success = success;
    item.error = error;
    item.then = then;
    item.progress = progress;
    item.alreadySent = NO;
    return item;
}
@end
