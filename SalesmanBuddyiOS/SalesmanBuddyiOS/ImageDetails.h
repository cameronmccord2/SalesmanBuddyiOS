//
//  ImageDetails.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/8/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDetails : NSObject

@property(nonatomic)NSInteger id;
@property(nonatomic, strong)NSString *photoName;
@property(nonatomic)NSInteger bucketId;
@property(nonatomic, strong)NSDate *created;
@property(nonatomic)NSInteger answerId;

+(NSDictionary *)dictionaryFromImageDetails:(ImageDetails *)imageDetails;
-(instancetype)initWithDictionary:(NSDictionary *)d;

@end
