//
//  QuestionAndAnswer.m
//  TruckerBid
//
//  Created by Cameron McCord on 12/16/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import "QuestionAndAnswer.h"

@implementation QuestionAndAnswer

+(NSDictionary *)dictionaryFromQuestionAndAnswer:(QuestionAndAnswer *)questionAndAnswer{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:[Question dictionaryFromQuestion:questionAndAnswer.question] forKey:@"question"];
    [d setValue:[Answer dictionaryFromAnswer:questionAndAnswer.answer] forKey:@"answer"];
    return d;
}

+(NSArray *)dictionaryArrayFromList:(NSArray *)array{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (QuestionAndAnswer *questionAndAnswer in array) {
        [list addObject:[QuestionAndAnswer dictionaryFromQuestionAndAnswer:questionAndAnswer]];
    }
    return list;
}

+(NSArray *)arrayFromDictionaryList:(NSArray *)array{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *d in array) {
        [list addObject:[[QuestionAndAnswer alloc] initWithDictionary:d]];
    }
    return list;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.question = [[Question alloc] initWithDictionary:dictionary[@"question"]];
        self.answer = [[Answer alloc] initWithDictionary:dictionary[@"answer"]];
    }
    return self;
}

@end
