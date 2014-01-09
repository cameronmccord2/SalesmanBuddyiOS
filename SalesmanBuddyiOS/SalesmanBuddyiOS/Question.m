//
//  Question.m
//  TruckerBid
//
//  Created by Cameron McCord on 12/16/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import "Question.h"

@implementation Question

+(NSDictionary *)dictionaryFromQuestion:(Question *)question{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:@(question.id) forKey:@"id"];
    [d setValue:@(question.version) forKey:@"version"];
    [d setValue:question.created forKey:@"created"];
    [d setValue:@(question.questionOrder) forKey:@"questionOrder"];
    [d setValue:question.questionTextEnglish forKey:@"questionTextEnglish"];
    [d setValue:question.questionTextSpanish forKey:@"questionTextSpanish"];
    [d setValue:@(question.questionType) forKey:@"questionType"];
    [d setValue:@(question.required) forKey:@"required"];
//    [d setValue:[DropdownOption dictionaryArrayFromList:question.dropdownOptions] forKey:@"dropdownOptions"];
    return d;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.version = [dictionary[@"version"] integerValue];
        self.questionOrder = [dictionary[@"questionOrder"] integerValue];
        self.questionTextEnglish = dictionary[@"questionTextEnglish"];
        self.questionTextSpanish = dictionary[@"questionTextSpanish"];
        self.questionType = [dictionary[@"questionType"] integerValue];
        self.required = [dictionary[@"required"] integerValue];
//        self.dropdownOptions = [DropdownOption arrayFromDictionaryList:dictionary[@"dropdownOptions"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        self.created = [dateFormat dateFromString:dictionary[@"created"]];
    }
    return self;
}

@end
