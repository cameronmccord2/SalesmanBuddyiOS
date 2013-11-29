//
//  AuthorizeQueue.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/27/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "AuthorizeQueue.h"

@implementation AuthorizeQueue

-(instancetype)initWithRequest:(NSMutableURLRequest *)request authDelegate:(id)authDelegate loginModalDelegate:(id)loginModalDelegate handler:(void (^)(NSError *))handler finishSelector:(SEL)sel{
    self = [super init];
    if (self != nil) {
        self.request = request;
        self.authDelegate = authDelegate;
        self.loginModalDelegate = loginModalDelegate;
        self.handler = handler;
        self.selector = sel;
        self.alreadyStarted = false;
    }
    return self;
}

+(instancetype)queuedRequest:(NSMutableURLRequest *)request authDelegate:(id)authDelegate loginModalDelegate:(id)loginModalDelegate handler:(void (^)(NSError *))handler finishSelector:(SEL)sel{
    return [[AuthorizeQueue alloc] initWithRequest:request authDelegate:authDelegate loginModalDelegate:loginModalDelegate handler:handler finishSelector:sel];
}
@end
