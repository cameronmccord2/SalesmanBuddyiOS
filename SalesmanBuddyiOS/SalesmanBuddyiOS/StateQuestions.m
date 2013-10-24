//
//  StateQuestions.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "StateQuestions.h"
#import "DAOManager.h"

@implementation StateQuestions

+(NSArray *)parseJsonArray:(NSArray *)json{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:json.count];
    for (NSDictionary *dictionary in json) {
        StateQuestions *s = [[StateQuestions alloc] initWithDictionary:dictionary];
        [array addObject:s];
    }
    return array;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.stateQuestionId = [dictionary[@"stateQuestionId"] integerValue];
        self.questionText = dictionary[@"questionText"];
        self.responseType = [dictionary[@"responseType"] integerValue];
        self.questionOrder = [dictionary[@"questionOrder"] integerValue];
        self.uniqueTag = [[DAOManager sharedManager] getAUniqueTag];
    }
    return self;
}
@end