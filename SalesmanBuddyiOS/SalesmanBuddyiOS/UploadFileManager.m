//
//  UploadFileManager.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/16/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "UploadFileManager.h"

@implementation UploadFileManager

+(id)sharedManagerWithContext:(NSManagedObjectContext *)managedContext{
    NSLog(@"context handed down: %@", managedContext);
    static UploadFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        NSLog(@"context set");
        sharedManager.context = managedContext;
    });
    return sharedManager;
}

@end
