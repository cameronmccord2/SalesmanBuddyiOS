//
//  License.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DAOManagerParseObjectProtocol;

@interface License : NSObject<DAOManagerParseObjectProtocol>

/*
 protected Integer id;
 protected Date created;
 protected Integer stateId;
 //custom here
 protected ArrayList<QuestionsAndAnswers> qaas;
 */

@property(nonatomic)NSInteger id;
@property(nonatomic)NSInteger stateId;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic, strong)NSMutableArray *qaas;

+(NSMutableArray *)arrayFromDictionaryList:(NSArray *)json;
+(NSDictionary *)dictionaryFromLicense:(License *)license;

-(id)initWithDictionary:(NSDictionary *)dictionary;
-(id)initWithQuestions:(NSArray *)questions;

@end
