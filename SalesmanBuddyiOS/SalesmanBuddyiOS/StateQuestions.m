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

+(NSDictionary *)dictionaryFromStateQuestions:(StateQuestions *)stateQuestions{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setObject:@(stateQuestions.stateQuestionsSpecificsId) forKey:@"stateQuestionsSpecificsId"];
    [d setObject:stateQuestions.responseText forKey:@"responseText"];
    [d setObject:@(stateQuestions.responseBool) forKey:@"responseBool"];
    return d;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.stateQuestionsSpecificsId = [dictionary[@"id"] integerValue];
        self.stateQuestionId = [dictionary[@"stateQuestionId"] integerValue];
        self.questionText = dictionary[@"questionText"];
        self.responseType = [dictionary[@"responseType"] integerValue];
        self.questionOrder = [dictionary[@"questionOrder"] integerValue];
        self.uniqueTag = [[DAOManager sharedManager] getAUniqueTag];
        self.responseText = [NSString stringWithFormat:@""];// used locally
        self.responseBool = 0;
    }
    return self;
}
@end
