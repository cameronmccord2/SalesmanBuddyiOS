//
//  MTCAuthManager.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/26/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2Authentication.h"
#import "MTCUser.h"

@interface MTCAuthManager : NSObject <NSXMLParserDelegate>{
    NSDecimalNumber *connectionNumber;
    
    NSNumber *typeGetUser;
    
    NSMutableDictionary *dataFromConnectionByTag;
    NSMutableDictionary *connections;
}

@property(nonatomic, strong)GTMOAuth2Authentication* auth;
@property(nonatomic, strong)NSString *kKeychainItemName;
@property(nonatomic, strong)NSString *kClientID;
@property(nonatomic, strong)NSString *kClientSecret;
@property(nonatomic, strong)NSString *scope;
@property(nonatomic, strong)NSMutableSet *scopes;
@property(nonatomic, strong)MTCUser *user;
@property(nonatomic, strong)NSString *error;
@property(nonatomic, strong)NSXMLParser *parser;
@property(nonatomic, strong)UIViewController *conrollerResponsibleForGoogleLogin;

+(MTCAuthManager *)sharedManager;

-(void)signOut;
-(void)addScope:(NSString *)scope;
-(BOOL)authorizeRequest:(NSMutableURLRequest *)request;
-(void)authorizeRequest:(NSMutableURLRequest *)request delegate:(id)delegate didFinishSelector:(SEL)sel;
-(void)authorizeRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(NSError *))handler;



@end

@protocol MTCAuthManagerDelegateProtocal <NSObject>

-(void)showAuthModal:(UIViewController *)viewController;
-(void)dismissAuthModal:(UIViewController *)viewController;

@optional

-(void)gotUser:(MTCUser *)user;
-(void)userCanceledLogin;

@end
