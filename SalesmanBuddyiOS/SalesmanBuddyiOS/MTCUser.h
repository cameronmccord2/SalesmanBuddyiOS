//
//  MTCUser.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/26/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTCUser : NSObject

+(NSDictionary *)dictionaryFromUser:(User *)user;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
