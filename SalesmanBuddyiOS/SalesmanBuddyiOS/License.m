//
//  License.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "License.h"

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

+(NSArray *)parseJson:(NSArray *)json{
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
        //        l.created = dictionary[date];
        self.contactInfo = [[ContactInfo alloc] initWithDictionary:dictionary[@"contactInfo"]];
    }
    return self;
}

@end
