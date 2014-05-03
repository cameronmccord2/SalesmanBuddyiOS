//
//  ImageDetails.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/8/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import "ImageDetails.h"

@implementation ImageDetails

/*
 @property(nonatomic)NSInteger id;
 @property(nonatomic, strong)NSString *photoName;
 @property(nonatomic)NSInteger bucketId;
 @property(nonatomic, strong)NSDate *created;
 @property(nonatomic)NSInteger answerId;
 */

+(NSDictionary *)dictionaryFromImageDetails:(ImageDetails *)imageDetails{
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    [d setValue:@(imageDetails.id) forKey:@"id"];
    [d setValue:imageDetails.photoName forKey:@"photoName"];
//    [d setValue:imageDetails.created forKey:@"created"];
    [d setValue:@(imageDetails.bucketId) forKey:@"bucketId"];
    [d setValue:@(imageDetails.answerId) forKey:@"answerId"];
    return d;
}

-(id)initWithDictionary:(NSDictionary *)dictionary{
//    NSLog(@"initing with dictionary, imageDetails: %@", dictionary);
    self = [super init];
    if (self) {
        self.id = [dictionary[@"id"] integerValue];
        self.photoName = dictionary[@"photoName"];
        self.bucketId = [dictionary[@"bucketId"] integerValue];
        self.answerId = [dictionary[@"answerId"] integerValue];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        self.created = [dateFormat dateFromString:dictionary[@"created"]];
    }
    return self;
}

@end
