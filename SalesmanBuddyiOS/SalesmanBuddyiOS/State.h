//
//  State.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface State : NSObject

@property(nonatomic)NSInteger id;
@property(nonatomic, strong)NSString *name;
@property(nonatomic)NSInteger status;

+(NSArray *)parseJsonArray:(NSArray *)json;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
