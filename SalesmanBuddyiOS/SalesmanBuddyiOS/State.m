//
//  State.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "State.h"

@implementation State

+(NSArray *)parseJsonArray:(NSArray *)json{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:json.count];
    for (NSDictionary *dictionary in json) {
        State *s = [[State alloc] initWithDictionary:dictionary];
        [array addObject:s];
    }
    return array;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.name = dictionary[@"name"];
        self.status = [dictionary[@"status"] integerValue];
    }
    return self;
}
@end
