//
//  User.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic)NSInteger id;
@property(nonatomic, strong)NSString *dealershipCode;
@property(nonatomic)NSInteger deviceType;
@property(nonatomic)NSInteger type;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic, strong)NSString *googleUserId;
@property(nonatomic, strong)NSString *refreshToken;

+(NSDictionary *)dictionaryFromUser:(User *)user;
+(instancetype)objectFromDictionary:(NSDictionary *)dictionary;
+(instancetype)userWithRefreshToken:(NSString *)refreshToken;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
