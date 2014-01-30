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
 // Licenses
 protected Integer id;
 protected Integer showInUserList;
 protected Integer stateId;
 protected Date created;
 protected float longitude;
 protected float latitude;
 protected Integer userId;
 
 // custom here
 protected ArrayList<QuestionsAndAnswers> qaas;
 */

@property(nonatomic)NSInteger id;
@property(nonatomic)NSInteger stateId;
@property(nonatomic)NSInteger showInUserList;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic)float longitude;
@property(nonatomic)float latitude;
@property(nonatomic, strong)NSMutableArray *qaas;

+(NSMutableArray *)arrayFromDictionaryList:(NSArray *)json;
+(NSDictionary *)dictionaryFromLicense:(License *)license;
+(instancetype)objectFromDictionary:(NSDictionary *)dictionary;

-(id)initWithDictionary:(NSDictionary *)dictionary;
-(id)initWithQuestions:(NSArray *)questions;

@end
