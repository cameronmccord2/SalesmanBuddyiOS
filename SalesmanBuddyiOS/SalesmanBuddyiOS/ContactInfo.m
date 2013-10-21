//
//  ContactInfo.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "ContactInfo.h"

@implementation ContactInfo
//@property(nonatomic)NSInteger id;
////@property(nonatomic)NSInteger userId;
//@property(nonatomic)NSInteger licenseId;
//@property(nonatomic, strong)NSDate *created;
//@property(nonatomic, strong)NSString *firstName;
//@property(nonatomic, strong)NSString *lastName;
//@property(nonatomic, strong)NSString *email;
//@property(nonatomic, strong)NSString *phoneNumber;
//@property(nonatomic, strong)NSString *streetAddress;
//@property(nonatomic, strong)NSString *city;
//@property(nonatomic)NSInteger stateId;
//@property(nonatomic, strong)NSString *notes;


-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.licenseId = [dictionary[@"licenseId"] integerValue];
//        self.created = dictionary[@"created"];
        self.firstName = dictionary[@"firstName"];
        self.lastName = dictionary[@"lastName"];
        self.email = dictionary[@"email"];
        self.phoneNumber = dictionary[@"phoneNumber"];
        self.streetAddress = dictionary[@"streetAddress"];
        self.city = dictionary[@"city"];
        self.stateId = [dictionary[@"stateId"] integerValue];
        self.notes = dictionary[@"notes"];
    }
    return self;
}

@end
