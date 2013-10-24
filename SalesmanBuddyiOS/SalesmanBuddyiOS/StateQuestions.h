//
//  StateQuestions.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateQuestions : NSObject

@property(nonatomic)NSInteger stateQuestionsSpecificsId;
@property(nonatomic)NSInteger stateQuestionId;
@property(nonatomic, strong)NSString *questionText;
@property(nonatomic)NSInteger responseType;
@property(nonatomic)NSInteger questionOrder;
@property(nonatomic)NSInteger uniqueTag;
@property(nonatomic, strong)NSString *responseText;
@property(nonatomic)NSInteger responseBool;

+(NSArray *)parseJsonArray:(NSArray *)json;
+(NSDictionary *)dictionaryFromStateQuestions:(StateQuestions *)stateQuestions;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
