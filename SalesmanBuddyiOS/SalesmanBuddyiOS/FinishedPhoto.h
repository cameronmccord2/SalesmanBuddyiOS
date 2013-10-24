//
//  FinishedPhoto.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FinishedPhoto : NSObject

@property(nonatomic, strong)NSString *filename;
@property(nonatomic)NSInteger bucketId;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
