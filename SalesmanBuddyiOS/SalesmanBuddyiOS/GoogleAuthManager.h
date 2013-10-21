//
//  GoogleAuthManager.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"

@interface GoogleAuthManager : NSObject

@property(nonatomic, strong)GTMOAuth2Authentication* auth;
@property(nonatomic, strong)NSString *kKeychainItemName;
@property(nonatomic, strong)NSString *kMyClientID;
@property(nonatomic, strong)NSString *kMyClientSecret;
@property(nonatomic, strong)NSString *scope;

+(GoogleAuthManager *)sharedManager;

@end

@protocol GoogleAuthManagerDelegateProtocal <NSObject>

-(void)runCall;

@end