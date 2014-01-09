//
//  Answer.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/16/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"
#import "ImageDetails.h"

@class DAOManager;

@interface Answer : NSObject<DAOManagerParseObjectProtocol>

/*
 protected Integer id;
 protected Integer answerBool;
 protected Integer answerType;
 protected String answerText;
 protected Integer licenseId;
 protected Date created;
 protected Integer questionId;
 protected ImageDetails imageDetails;
 */

@property(nonatomic)NSInteger id;
@property(nonatomic)NSInteger answerBool;
@property(nonatomic)NSInteger answerType;
@property(nonatomic, strong)NSString *answerText;
@property(nonatomic)NSInteger licenseId;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic)NSInteger questionId;
@property(nonatomic, strong)ImageDetails *imageDetails;

+(NSDictionary *)dictionaryFromAnswer:(Answer *)answer;

-(instancetype)initWithDictionary:(NSDictionary *)d;
-(instancetype)initWithQuestion:(Question *)question;

@end
