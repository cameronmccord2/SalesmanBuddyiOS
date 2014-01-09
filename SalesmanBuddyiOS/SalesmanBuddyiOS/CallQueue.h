//
//  CallQueue.h
//  Item Mapper
//
//  Created by Cameron McCord on 8/23/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSURLConnectionWithExtras.h"

@protocol DAOManagerDelegateProtocal;

@interface CallQueue : NSObject

@property(nonatomic)BOOL alreadySent;
@property(nonatomic, strong)id<DAOManagerDelegateProtocal> delegate;
@property(nonatomic, strong)NSMutableURLRequest *request;
@property(nonatomic, strong)NSDictionary *body;
@property(nonatomic, copy)void (^success)(NSData *, void(^)());
@property(nonatomic, copy)void (^error)(NSData *, NSError *, void(^)());
@property(nonatomic, copy)void (^then)(NSData *, NSURLConnectionWithExtras *, NSProgress *);

+(instancetype)initWithRequest:(NSMutableURLRequest *)request body:(NSDictionary *)body authDelegate:(id<DAOManagerDelegateProtocal>)authDelegate success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *, NSURLConnectionWithExtras *, NSProgress *))then;

@end