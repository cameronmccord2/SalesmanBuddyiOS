//
//  UploadFileManager.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/16/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadFileManager : NSObject

@property(nonatomic, strong)NSManagedObjectContext *context;

+(id)sharedManagerWithContext:(NSManagedObjectContext *)managedContext;

@end
