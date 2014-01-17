//
//  License.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "License.h"
#import "QuestionAndAnswer.h"

@implementation License

+(NSMutableArray *)arrayFromDictionaryList:(NSArray *)json{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in json) {
        [array addObject:[[License alloc] initWithDictionary:dictionary]];
    }
    return array;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"yyyy-MM-dd"];
//        self.created = [dateFormat dateFromString:dictionary[@"created"]];
//        NSLog(@"from object: %@", self.created);
//        NSLog(@"from dictionary: %@", dictionary[@"created"]);
//        NSLog(@"from formatter: %@", [dateFormat dateFromString:dictionary[@"created"]]);
        self.created = dictionary[@"created"];
        self.stateId = [dictionary[@"stateId"] integerValue];
        self.qaas = [[QuestionAndAnswer arrayFromDictionaryList:dictionary[@"qaas"]] mutableCopy];
    }
    return self;
}

-(id)initWithQuestions:(NSArray *)questions{
    self = [super init];
    if (self) {
        self.id = 0;
        self.created = [NSDate date];
        self.qaas = [[NSMutableArray alloc] initWithCapacity:[questions count]];
        for (Question *q in questions) {
            QuestionAndAnswer *qaa = [[QuestionAndAnswer alloc] init];
            qaa.question = q;
            qaa.answer = [[Answer alloc] initWithQuestion:q];
            [self.qaas addObject:qaa];
        }
    }
    return self;
}

+(NSDictionary *)dictionaryFromLicense:(License *)license{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:[NSNumber numberWithInt:license.id] forKey:@"id"];
    [d setValue:@(license.stateId) forKey:@"stateId"];
    NSMutableArray *qaas = [[NSMutableArray alloc] initWithCapacity:license.qaas.count];
    for (QuestionAndAnswer *qaa in license.qaas) {
        [qaas addObject:[QuestionAndAnswer dictionaryFromQuestionAndAnswer:qaa]];
    }
    [d setObject:qaas forKey:@"qaas"];
    return d;
}

@end


























