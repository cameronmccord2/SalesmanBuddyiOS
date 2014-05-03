//
//  User.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.dealershipCode = dictionary[@"dealershipCode"];
        self.deviceType = [dictionary[@"deviceType"] integerValue];
        self.type = [dictionary[@"type"] integerValue];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        self.created = [dateFormat dateFromString:dictionary[@"created"]];
        self.googleUserId = dictionary[@"googleUserId"];
        self.refreshToken = dictionary[@"refreshToken"];
    }
    return self;
}

//-(id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super init];
//    if(self){
//        self.id = [aDecoder decodeIntegerForKey:@"id"];
//        self.dealershipId = [aDecoder decodeIntegerForKey:@"dealershipId"];
//        self.deviceType = [aDecoder decodeIntegerForKey:@"deviceType"];
//        self.type = [aDecoder decodeIntegerForKey:@"type"];
//        self.googleUserId = [aDecoder decodeObjectForKey:@"googleUserId"];
//    }
//    return self;
//}
//
//-(void)encodeWithCoder:(NSCoder *)encoder{
//    [encoder encodeInteger:self.deviceType forKey:@"deviceType"];
//    [encoder encodeObject:self.googleUserId forKey:@"googleUserId"];
//}

+(NSDictionary *)dictionaryFromUser:(User *)user{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:@(user.id) forKey:@"id"];
    [d setValue:user.dealershipCode forKey:@"dealershipCode"];
    [d setValue:@(user.deviceType) forKey:@"deviceType"];
    [d setValue:@(user.type) forKey:@"type"];
    [d setValue:user.googleUserId forKey:@"googleUserId"];
    [d setValue:user.refreshToken forKey:@"refreshToken"];
    return d;
}

+(instancetype)userWithRefreshToken:(NSString *)refreshToken{
    User *u = [[User alloc] init];
    u.deviceType = 1;// 1:ios, 2:web, 3:android, this indicates which client the refresh token came from
    u.refreshToken = refreshToken;
    return u;
}

+(instancetype)objectFromDictionary:(NSDictionary *)dictionary{
    return [[User alloc] initWithDictionary:dictionary];
}

@end
