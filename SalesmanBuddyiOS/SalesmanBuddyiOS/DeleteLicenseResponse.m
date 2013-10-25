//
//  DeleteLicenseResponse.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "DeleteLicenseResponse.h"

@implementation DeleteLicenseResponse

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.message = dictionary[@"message"];
        self.success = [dictionary[@"success"] integerValue];
        self.licenseId = [dictionary[@"licenseId"] integerValue];
    }
    return self;
}

@end
