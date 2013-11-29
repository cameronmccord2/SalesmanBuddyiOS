//
//  AuthorizeQueue.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/27/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorizeQueue : NSObject

@property(nonatomic, strong)NSMutableURLRequest *request;
@property(nonatomic, strong)id authDelegate;
@property(nonatomic, strong)id loginModalDelegate;
@property(nonatomic, strong)id handler;
@property(nonatomic)SEL selector;
@property(nonatomic)BOOL alreadyStarted;

-(instancetype)initWithRequest:(NSMutableURLRequest *)request authDelegate:(id)authDelegate loginModalDelegate:(id)loginModalDelegate handler:(void (^)(NSError *))handler finishSelector:(SEL)sel;

+(instancetype)queuedRequest:(NSMutableURLRequest *)request authDelegate:(id)authDelegate loginModalDelegate:(id)loginModalDelegate handler:(void (^)(NSError *))handler finishSelector:(SEL)sel;

@end
