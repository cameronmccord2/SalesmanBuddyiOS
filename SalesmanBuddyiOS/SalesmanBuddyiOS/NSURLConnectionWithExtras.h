//
//  NSURLConnectionWithExtras.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/29/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnectionWithExtras : NSURLConnection

@property (nonatomic, strong)NSDecimalNumber *uniqueTag;
@property (nonatomic, strong)id finalDelegate;
@property(nonatomic, strong)NSProgress *nsProgress;

@property(nonatomic, copy)void (^success)(NSData *, void(^)());
@property(nonatomic, copy)void (^error)(NSData *, NSError *, void(^)());
@property(nonatomic, copy)void (^then)(NSData *);
@property(nonatomic, copy)void (^progress)(NSProgress *);

+(instancetype)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately uniqueTag:(NSDecimalNumber *)uniqueTag finalDelegate:(id)finalDelegate success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress;

-(instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately uniqueTag:(NSDecimalNumber *)uniqueTag finalDelegate:(id)finalDelegate success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress;


@end
