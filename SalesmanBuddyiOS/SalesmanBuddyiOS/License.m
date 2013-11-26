//
//  License.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "License.h"
#import "StateQuestions.h"

@implementation License

//@property(nonatomic)NSInteger id;
//@property(nonatomic)NSInteger showInUserList;
//@property(nonatomic, strong)NSString *photo;
//@property(nonatomic)NSInteger bucketId;
//@property(nonatomic, strong)NSDate *created;
//@property(nonatomic)float longitude;
//@property(nonatomic)float latitude;
//@property(nonatomic)NSInteger userId;
//@property(nonatomic, strong)ContactInfo *contactInfo;

+(NSMutableArray *)parseJsonArray:(NSArray *)json{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in json) {
        [array addObject:[[License alloc] initWithDictionary:dictionary]];
    }
    return array;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.photo = dictionary[@"photo"];
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"yyyy-MM-dd"];
//        self.created = [dateFormat dateFromString:dictionary[@"created"]];
//        NSLog(@"from object: %@", self.created);
//        NSLog(@"from dictionary: %@", dictionary[@"created"]);
//        NSLog(@"from formatter: %@", [dateFormat dateFromString:dictionary[@"created"]]);
        self.created = dictionary[@"created"];
        self.contactInfo = [[ContactInfo alloc] initWithDictionary:dictionary[@"contactInfo"]];
        self.stateQuestionsResponses = [StateQuestions parseJsonArray:dictionary[@"stateQuestions"]];
    }
    return self;
}

+(NSDictionary *)dictionaryFromLicense:(License *)license{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:[NSNumber numberWithInt:license.id] forKey:@"id"];
    [d setValue:license.photo forKey:@"photo"];
    [d setValue:@(license.stateId) forKey:@"stateId"];
    [d setValue:@(license.longitude) forKey:@"longitude"];// not for update
    [d setValue:@(license.latitude) forKey:@"latitude"];// not for update
    [d setObject:[ContactInfo dictionaryFromContactInfo:license.contactInfo] forKey:@"contactInfo"];
    NSMutableArray *stateQuestionsResponses = [[NSMutableArray alloc] initWithCapacity:license.stateQuestionsResponses.count];
    for (StateQuestions *sq in license.stateQuestionsResponses) {
        [stateQuestionsResponses addObject:[StateQuestions dictionaryFromStateQuestions:sq]];
    }
    [d setObject:stateQuestionsResponses forKey:@"stateQuestionsResponses"];
    return d;
}

@end
