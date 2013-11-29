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
@property(nonatomic, strong)UIViewController *conrollerResponsibleForLogin;
@property(nonatomic, strong)NSMutableArray *queue;
@property(nonatomic)BOOL alreadyAuthorizing;

+(MTCAuthManager *)sharedManager;

-(void)forceLogin:(id)delegate;
-(void)signOut;
-(void)addScope:(NSString *)scope;
-(BOOL)canAuthorize;
//-(BOOL)authorizeRequest:(NSMutableURLRequest *)request;// not set up for syncro
-(void)authorizeRequest:(NSMutableURLRequest *)request authDelegate:(id)authDelegate loginModalDelegate:(id)loginModalDelegate didFinishSelector:(SEL)sel;
-(void)authorizeRequest:(NSMutableURLRequest *)request authDelegate:(id)authDelegate loginModalDelegate:(id)loginModalDelegate completionHandler:(void (^)(NSError *))handler;
-(void)authGaveError:(NSError *)error;


@end

@protocol MTCAuthManagerDAODelegateProtocal <NSObject>

@optional

-(void)gotUser:(MTCUser *)user;
-(void)userCanceledLogin;

@end

@protocol MTCAuthManagerViewControllerDelegateProtocal <NSObject>

-(void)showAuthModal:(UIViewController *)viewController;
-(void)dismissAuthModal:(UIViewController *)viewController;

@end
