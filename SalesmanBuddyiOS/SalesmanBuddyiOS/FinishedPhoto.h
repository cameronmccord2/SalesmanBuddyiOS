//
//  FinishedPhoto.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DAOManagerParseObjectProtocol;

@interface FinishedPhoto : NSObject <DAOManagerParseObjectProtocol>

@property(nonatomic, strong)NSString *filename;
@property(nonatomic)NSInteger bucketId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
+(instancetype)objectFromDictionary:(NSDictionary *)dictionary;

@end
