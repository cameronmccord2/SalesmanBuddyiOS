//
//  DAOManager.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/17/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "DAOManager.h"
#import "NSURLConnectionWithTag.h"
#import "CallQueue.h"

@implementation DAOManager

+(DAOManager *)sharedManager{
    static DAOManager *sharedManager;
    @synchronized(self){// this is if multiple threads do this at the exact same time
        if (!sharedManager) {
            sharedManager = [[DAOManager alloc] init];
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

//-(void)makeSureUserIsReady:(id)delegate{
//    if (![self hasToken]) {
//        [self showGoogleLogin];
//    }
//    if ([delegate respondsToSelector:@selector(userIsReady)]) {
//        [delegate userIsReady];
//    }else
//        NSLog(@"delegate error, cant call userIsReady");
//}

#pragma mark - Authentication stuff

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

- (void)authentication:(GTMOAuth2Authentication *)auth
               request:(NSMutableURLRequest *)request
     finishedWithError:(NSError *)error{
    if(error != nil){
        NSLog(@"authorization failed: %@", error.localizedDescription);
    }else{
        
    }
}

-(void)makeAuthViable:(id)delegate{
    // Get the saved authentication, if any, from the keychain.
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:self.kKeychainItemName
                                                                 clientID:self.kMyClientID
                                                             clientSecret:self.kMyClientSecret];
    
    // We can determine later if the auth object contains an access token by calling its -canAuthorize method
    if (![self.auth canAuthorize]) {
        NSLog(@"auth cannot authorize");
        [self showGoogleLogin];
    }else{
        self.auth = auth;
        if ([delegate respondsToSelector:@selector(authIsViable)]) {
            [delegate performSelector:@selector(authIsViable)];
        }
    }
}

-(void)signOutOfGoogle{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}


#pragma mark - Connection Stuff

//Post function
-(NSURLRequest *)makePostRequest:(NSURL *)url body:(id)bodyData forType:(NSNumber *)type finalDelegate:(id)delegate{
    NSError *error = nil;
    NSMutableURLRequest *req = [NSURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    if(bodyData){
        NSData *postData = [NSJSONSerialization dataWithJSONObject:bodyData options:NSJSONWritingPrettyPrinted error:&error];
        [req setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody:postData];
    }
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    
}

// Queue stuff
-(void)doFetchQueue{
    if (callQueue.count != 0) {
        for (CallQueue *cq in callQueue) {
            if (!cq.alreadySent) {
                [self doRequest:cq.fullUrl body:cq.body forType:cq.type finalDelegate:cq.delegate];
            }
        }
    }
}

// Initialize Connection
-(void)doRequest:(NSURLRequest *)request forType:(NSNumber *)type finalDelegate:(id)delegate{
    [connections setObject:[[NSURLConnectionWithTag alloc]initWithRequest:request delegate:self startImmediately:YES typeTag:type uniqueTag:connectionNumber finalDelegate:delegate] forKey:connectionNumber];
    [connectionNumber decimalNumberByAdding:[NSDecimalNumber one]];
}

// Connection handling
-(void)connection:(NSURLConnectionWithTag *)connection didReceiveData:(NSData *)data{
    if ([dataFromConnectionByTag objectForKey:connection.uniqueTag] == nil) {
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        [dataFromConnectionByTag setObject:newData forKey:connection.uniqueTag];
        return;
    }else{
        [[dataFromConnectionByTag objectForKey:connection.uniqueTag] appendData:data];
    }
}

// TODO connection needs to store the final delegate******************************************************************************************************************************
-(void)connectionDidFinishLoading:(NSURLConnectionWithTag *)conn{
    if ([dataFromConnectionByTag objectForKey:conn.uniqueTag]) {
        if ([conn.typeTag isEqualToNumber:typeMyItems]) {// history, code, attributes, location
            // parse my items and return it to delegate
        }else if([conn.typeTag isEqualToNumber:typeDoesItemExist]){// history, code, attributes
            // parse and return
        }
//        else if([conn.typeTag isEqualToNumber:typeAuthenticate]){// token:id, token, userId, created, type, status
//            // parse and return
//        }
    }else
        NSLog(@"couldnt find data for typeTag: %@", conn.typeTag);
    
    // clean up
    [dataFromConnectionByTag removeObjectForKey:conn.uniqueTag]; // after done using the data, remove it
    [connections removeObjectForKey:conn.uniqueTag];// remove the connection
}

-(void)connection:(NSURLConnectionWithTag *)conn didFailWithError:(NSError *)error{
//    if ([conn.typeTag isEqualToNumber:typeAuthenticate]) {
//        //        conn.
//    }
    NSString *errorString = [NSString stringWithFormat:@"Fetch  failed for url: %@, error: %@", conn.originalRequest.URL.absoluteString, [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}


@end








































