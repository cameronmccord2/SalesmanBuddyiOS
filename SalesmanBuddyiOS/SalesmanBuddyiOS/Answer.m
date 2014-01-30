//
//  Answer.m
//  TruckerBid
//
//  Created by Cameron McCord on 12/16/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import "Answer.h"

@implementation Answer

+(NSDictionary *)dictionaryFromAnswer:(Answer *)answer{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:@(answer.id) forKey:@"id"];
    [d setValue:@(answer.answerBool) forKey:@"answerBool"];
    [d setValue:@(answer.answerType) forKey:@"answerType"];
    [d setValue:answer.answerText forKey:@"answerText"];
    [d setValue:@(answer.licenseId) forKey:@"licenseId"];
//    [d setValue:answer.created forKey:@"created"];
    [d setValue:@(answer.questionId) forKey:@"questionId"];
    [d setValue:[ImageDetails dictionaryFromImageDetails:answer.imageDetails] forKey:@"imageDetails"];
    return d;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    NSLog(@"initing with dictionary, answer: %@", dictionary);
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.answerBool = [dictionary[@"answerBool"] integerValue];
        self.answerType = [dictionary[@"answerType"] integerValue];
        self.answerText = dictionary[@"answerText"];
        self.licenseId = [dictionary[@"licenseId"] integerValue];
        self.questionId = [dictionary[@"questionId"] integerValue];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        self.created = [dateFormat dateFromString:dictionary[@"created"]];
        self.imageDetails = [[ImageDetails alloc] initWithDictionary:dictionary[@"imageDetails"]];
    }
    return self;
}

-(instancetype)initWithQuestion:(Question *)question{
    self = [super init];
    if (self) {
        self.id = 0;
        self.answerBool = 0;
        self.answerType = question.questionType;
        self.answerText = @"";
        self.licenseId = 0;
        self.questionId = question.id;
        self.created = [NSDate date];
        self.imageDetails = [[ImageDetails alloc] init];
    }
    return self;
}

@end
