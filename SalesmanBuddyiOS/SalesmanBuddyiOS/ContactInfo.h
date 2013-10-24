//
//  ContactInfo.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactInfo : NSObject

@property(nonatomic)NSInteger id;
//@property(nonatomic)NSInteger userId;
@property(nonatomic)NSInteger licenseId;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic, strong)NSString *firstName;
@property(nonatomic, strong)NSString *lastName;
@property(nonatomic, strong)NSString *email;
@property(nonatomic, strong)NSString *phoneNumber;
@property(nonatomic, strong)NSString *streetAddress;
@property(nonatomic, strong)NSString *city;
@property(nonatomic)NSInteger stateId;
@property(nonatomic, strong)NSString *notes;

+(NSDictionary *)dictionaryFromContactInfo:(ContactInfo *)contactInfo;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
