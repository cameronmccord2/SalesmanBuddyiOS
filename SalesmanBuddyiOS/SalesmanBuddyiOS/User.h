//
//  User.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>

@property(nonatomic)NSInteger id;
@property(nonatomic)NSInteger dealershipId;
@property(nonatomic)NSInteger deviceType;
@property(nonatomic)NSInteger type;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic, strong)NSString *googleUserId;

+(NSDictionary *)dictionaryFromUser:(User *)user;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
