//
//  DeleteLicenseResponse.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteLicenseResponse : NSObject

@property(nonatomic, strong)NSString *message;
@property(nonatomic)NSInteger success;
@property(nonatomic)NSInteger licenseId;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
