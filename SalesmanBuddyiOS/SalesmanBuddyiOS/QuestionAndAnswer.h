//
//  QuestionAndAnswer.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/16/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Answer.h"

@interface QuestionAndAnswer : NSObject

@property(nonatomic, strong)Question *question;
@property(nonatomic, strong)Answer *answer;

+(NSDictionary *)dictionaryFromQuestionAndAnswer:(QuestionAndAnswer *)questionAndAnswer;
+(NSArray *)dictionaryArrayFromList:(NSArray *)array;
+(NSArray *)arrayFromDictionaryList:(NSArray *)array;

-(instancetype)initWithDictionary:(NSDictionary *)d;

@end
