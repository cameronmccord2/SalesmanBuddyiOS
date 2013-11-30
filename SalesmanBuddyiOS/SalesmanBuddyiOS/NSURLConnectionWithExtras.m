//
//  NSURLConnectionWithExtras.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/29/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "NSURLConnectionWithExtras.h"

@implementation NSURLConnectionWithExtras

+(instancetype)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately uniqueTag:(NSDecimalNumber *)uniqueTag finalDelegate:(id)finalDelegate success:(void (^)(NSData *, void (^)()))success error:(void (^)(NSData *, NSError *, void (^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress{
    return [[NSURLConnectionWithExtras alloc] initWithRequest:request delegate:delegate startImmediately:startImmediately uniqueTag:uniqueTag finalDelegate:finalDelegate success:success error:error then:then progress:progress];
}

-(instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately uniqueTag:(NSDecimalNumber *)uniqueTag finalDelegate:(id)finalDelegate success:(void (^)(NSData *, void (^)()))success error:(void (^)(NSData *, NSError *, void (^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress{
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    if (self != nil) {
        self.uniqueTag = uniqueTag;
        self.finalDelegate = finalDelegate;
        self.success = success;
        self.error = error;
        self.then = then;
        self.progress = progress;
        self.nsProgress = [[NSProgress alloc] init];
    }
    return self;
}

@end
