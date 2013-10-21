//
//  GoogleAuthManager.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/18/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "GoogleAuthManager.h"

@implementation GoogleAuthManager

+(GoogleAuthManager *)sharedManager{
    static GoogleAuthManager *sharedManager;
    @synchronized(self){// this is if multiple threads do this at the exact same time
        if (!sharedManager) {
            sharedManager = [[GoogleAuthManager alloc] init];
        }
        return sharedManager;
    }
}

-(id)init{
    self = [super init];
    if (self) {
        self.kKeychainItemName = @"SalesmanCompanionKeyV1";
        self.kMyClientID = @"38235450166-dgbh1m7aaab7kopia2upsdj314odp8fc.apps.googleusercontent.com";     // pre-assigned by service
        self.kMyClientSecret = @"zC738ZbMHopT2C1cyKiKDBQ6"; // pre-assigned by service
        self.scope = @"https://www.googleapis.com/auth/plus.me"; // scope for Google+ API
    }
    return self;
}

-(void)showGoogleLogin{
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:self.scope
                                                                clientID:self.kMyClientID
                                                            clientSecret:self.kMyClientSecret
                                                        keychainItemName:self.kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authObject error:(NSError *)error{
    if(error != nil){
        NSLog(@"%ld", (long)error.code);
        if (error.code == -1000) {
            NSLog(@"User closed the login modal before authenticating");
        }
    }else{
        self.auth = authObject;
        [self makeAuthViableAndExecuteCallQueue];
    }
}

-(void)authorizeRequest:(NSMutableURLRequest *)request didFinishSelector:(SEL)selector{
    if (![self.auth canAuthorize]) {
        NSLog(@"auth cant authorize");
        [self showGoogleLogin];// add another callback here to continue with the request?
    }else{
        [self.auth authorizeRequest:request delegate:self didFinishSelector:@selector(authentication:request:finishedWithError:)];// async if it has to refresh the token
    }
}

- (void)authentication:(GTMOAuth2Authentication *)auth request:(NSMutableURLRequest *)request finishedWithError:(NSError *)error{
    if(error != nil){
        NSLog(@"authorization failed: %@", error.localizedDescription);
    }else{
        NSLog(@"authentication success");
    }
}

-(void)makeAuthViableAndExecuteCallQueue:(id)delegate{
    GTMOAuth2Authentication *auth;
    if (self.auth == nil) {
        NSLog(@"getting auth from keychain");
        // Get the saved authentication, if any, from the keychain.
        auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:self.kKeychainItemName
                                                                     clientID:self.kMyClientID
                                                                 clientSecret:self.kMyClientSecret];
    }else
        auth = self.auth;
    
    // We can determine later if the auth object contains an access token by calling its -canAuthorize method
    if (![auth canAuthorize]) {
        NSLog(@"auth cannot authorize");
        [self showGoogleLogin];
    }else{
        NSLog(@"auth can authorize");
        self.auth = auth;
        if ([delegate respondsToSelector:@selector(runCall)]) {
            [delegate performSelector:@selector(runCall)];
        }else
            NSLog(@"delegate cant respond to runCall selector");
    }
}

-(void)signOutOfGoogle{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}

@end
