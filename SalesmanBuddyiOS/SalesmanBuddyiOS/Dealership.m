//
//  Dealership.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "Dealership.h"

@implementation Dealership

+(NSArray *)parseJsonArray:(NSArray *)json{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:json.count];
    for (NSDictionary *dictionary in json) {
        Dealership *d = [[Dealership alloc] initWithDictionary:dictionary];
        [array addObject:d];
    }
    return array;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.name = dictionary[@"name"];
        self.city = dictionary[@"city"];
        self.stateId = [dictionary[@"stateId"] integerValue];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        self.created = [dateFormat dateFromString:dictionary[@"created"]];
    }
    return self;
}

@end
