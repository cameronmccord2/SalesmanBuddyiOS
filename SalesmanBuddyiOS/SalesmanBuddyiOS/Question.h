//
//  Question.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/16/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Question : NSObject

/*
 protected Integer id;
 protected Integer version;
 protected Date created;
 protected Integer questionOrder;
 protected String questionTextEnglish;
 protected String questionTextSpanish;
 protected Integer questionType;
 protected Integer required;
 */

@property(nonatomic)NSInteger id;
@property(nonatomic)NSInteger version;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic)NSInteger questionOrder;
@property(nonatomic, strong)NSString *questionTextEnglish;
@property(nonatomic, strong)NSString *questionTextSpanish;
@property(nonatomic)NSInteger questionType;
@property(nonatomic)NSInteger required;

+(NSDictionary *)dictionaryFromQuestion:(Question *)question;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
