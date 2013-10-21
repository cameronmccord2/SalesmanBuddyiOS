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
#import "License.h"

@implementation DAOManager

NSString *baseUrl = @"http://localhost:8080/itemMapper/v1/";
NSString *licensesUrl = @"licenses";

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
        
        callQueue = [[NSMutableArray alloc] init];
        tryingToAuthenticate = false;
        
        connectionNumber = [NSDecimalNumber zero];
        typeLicenses = [[NSDecimalNumber alloc] initWithInt:1];
        typeOther = [[NSDecimalNumber alloc] initWithInt:2];
    }
    return self;
}




#pragma mark - Connection Stuff

//Post function
-(NSURLRequest *)makePostRequest:(NSURL *)url body:(id)bodyData forType:(NSNumber *)type finalDelegate:(id)delegate{
    NSError *error = nil;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
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
    }else{
        return req;
    }
}

-(void)getLicensesForDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeLicenses body:nil delegate:delegate]];
    [self makeAuthViableAndExecuteCallQueue];
}



#pragma mark - Fetch Queue

-(void)doFetchQueue{
    if (!tryingToAuthenticate && callQueue.count != 0) {
        for (CallQueue *cq in callQueue) {
            if (!cq.alreadySent) {
                [self doRequest:cq];
                break;
            }
        }
    }
}

// Initialize Connection
-(void)doRequest:(CallQueue *)cq{
    if (self.auth == nil) {
        NSLog(@"auth is nil");
        [self showGoogleLogin];
    }else{
        cq.alreadySent = true;
        [self.auth authorizeRequest:cq.request completionHandler:^(NSError *error) {
            if (error == nil) {// success
                tryingToAuthenticate = false;
                [connections setObject:[[NSURLConnectionWithTag alloc]initWithRequest:cq.request delegate:self startImmediately:YES typeTag:cq.type uniqueTag:connectionNumber finalDelegate:cq.delegate] forKey:connectionNumber];
                [connectionNumber decimalNumberByAdding:[NSDecimalNumber one]];
                [self doFetchQueue];
            }else{
                NSLog(@"failed to authorize request");
                if (![self.auth canAuthorize]) {
                    NSLog(@"auth cannot authorize");
                }
                cq.alreadySent = false;
                [self showGoogleLogin];
            }
        }];
    }
}

#pragma mark - Connection Handling
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
    NSError *e = nil;
    if ([dataFromConnectionByTag objectForKey:conn.uniqueTag]) {
        if ([conn.typeTag isEqualToNumber:typeLicenses]) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
            }else if ([conn.finalDelegate respondsToSelector:@selector(licenses:)]) {
                [conn.finalDelegate performSelector:@selector(licenses:) withObject:[License parseJsonArray:jsonArray]];
            }else
                NSLog(@"cannot send licenses to delegate");
        }else if([conn.typeTag isEqualToNumber:typeOther]){// history, code, attributes
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


#pragma mark - Google oauth2 stuff

-(void)showGoogleLogin{
    NSLog(@"going to show google login");
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:self.scope
                                                                clientID:self.kMyClientID
                                                            clientSecret:self.kMyClientSecret
                                                        keychainItemName:self.kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:viewController animated:YES completion:nil];
    // calls -(void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
}


-(void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    if (error != nil) {
        NSLog(@"%ld", (long)error.code);
        if (error.code == -1000) {
            NSLog(@"User closed the login modal before authenticating");
        }else
            NSLog(@"unsupported error code");
    } else {
        self.auth = auth;
        NSLog(@"got authentication back, success");
        if (![auth canAuthorize]) {
            NSLog(@"error, came back but cant authorize, never should happen");
        }
        tryingToAuthenticate = false;
        [self doFetchQueue];
    }
}

-(void)makeAuthViableAndExecuteCallQueue{
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
        [self doFetchQueue];
    }
}

-(void)signOutOfGoogle{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}


@end








































