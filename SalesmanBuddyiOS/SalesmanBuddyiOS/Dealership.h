//
//  Dealership.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dealership : NSObject

@property(nonatomic)NSInteger id;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *city;
@property(nonatomic)NSInteger stateId;
@property(nonatomic, strong)NSDate *created;

+(NSArray *)parseJsonArray:(NSArray *)json;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
