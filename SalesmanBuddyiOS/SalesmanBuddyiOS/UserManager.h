//
//  UserManager.h
//  Item Mapper
//
//  Created by Cameron McCord on 8/23/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"

@interface UserManager : NSObject

@property(nonatomic, strong)GTMOAuth2Authentication* auth;

+(id)sharedManager;

-(void)makeSureUserIsReady:(id)delegate;

-(BOOL)hasToken;
-(NSString *)getToken;
-(BOOL)setToken;
-(BOOL)deleteToken;
-(BOOL)hasUsername;
-(NSString *)getUsername;
-(BOOL)setUsername;
-(BOOL)deleteUsername;
-(BOOL)hasPassword;
-(NSString *)getPassword;
-(BOOL)setPassword;
-(BOOL)deletePassword;
-(BOOL)deleteEverything;

// google callbacks
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error;


@end

@protocol UserManagerDelegateProtocal <NSObject>

-(void)userIsReady;

@end
