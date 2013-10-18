//
//  DAOManager.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/17/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"

@interface DAOManager : NSObject{
    NSMutableArray *licenses;
    NSMutableArray *callQueue;
    NSDecimalNumber *connectionNumber;
    NSMutableDictionary *dataFromConnectionByTag;
    NSMutableDictionary *connections;
}

@property(nonatomic, strong)GTMOAuth2Authentication* auth;
@property(nonatomic, strong)NSString *kKeychainItemName;
@property(nonatomic, strong)NSString *kMyClientID;
@property(nonatomic, strong)NSString *kMyClientSecret;
@property(nonatomic, strong)NSString *scope;

+(DAOManager *)sharedManager;
-(void)makeAuthViable;
-(void)signOutOfGoogle;


// google callbacks
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;

@end

@protocol DAOManagerDelegateProtocal <NSObject>

-(void)authIsViable;

@end