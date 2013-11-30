//
//  CallQueue.h
//  Item Mapper
//
//  Created by Cameron McCord on 8/23/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallQueue : NSObject{

}

@property(nonatomic)BOOL alreadySent;
@property(nonatomic, strong)id delegate;
@property(nonatomic, strong)NSMutableURLRequest *request;
@property(nonatomic, strong)NSDictionary *body;
@property(nonatomic, copy)void (^success)(NSData *, void(^)());
@property(nonatomic, copy)void (^error)(NSData *, NSError *, void(^)());
@property(nonatomic, copy)void (^then)(NSData *);
@property(nonatomic, copy)void (^progress)(NSProgress *);


-(id)initQueueItem:(NSMutableURLRequest *)newRequest body:(NSDictionary *)newBody delegate:(id)newDelegate;
+(instancetype)initWithRequest:(NSMutableURLRequest *)request body:(NSDictionary *)body delegate:(id)delegate success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress;
@end
