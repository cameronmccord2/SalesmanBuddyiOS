//
//  StateQuestions.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/22/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateQuestions : NSObject

@property(nonatomic)NSInteger id;
@property(nonatomic)NSInteger stateQuestionId;
@property(nonatomic, strong)NSString *questionText;
@property(nonatomic)NSInteger responseType;
@property(nonatomic)NSInteger questionOrder;
@property(nonatomic)NSInteger uniqueTag;

+(NSArray *)parseJsonArray:(NSArray *)json;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
