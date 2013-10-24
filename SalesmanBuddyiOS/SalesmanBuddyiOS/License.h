//
//  License.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactInfo.h"

@interface License : NSObject

@property(nonatomic)NSInteger id;
//@property(nonatomic)NSInteger showInUserList;
@property(nonatomic, strong)NSString *photo;
@property(nonatomic)NSInteger stateId;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic)float longitude;
@property(nonatomic)float latitude;
//@property(nonatomic)NSInteger userId;
@property(nonatomic, strong)ContactInfo *contactInfo;
@property(nonatomic, strong)NSArray *stateQuestionsResponses;

+(NSArray *)parseJsonArray:(NSArray *)json;
+(NSDictionary *)dictionaryFromLicense:(License *)license;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
