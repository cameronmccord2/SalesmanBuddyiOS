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
#import "NewUserModalViewController.h"
#import "Dealership.h"
#import "State.h"
#import "StateQuestions.h"
#import "ClassAdditions.m"

@implementation DAOManager

NSString *baseUrl = @"http://salesmanbuddytest1.elasticbeanstalk.com/v1/salesmanbuddy/";
NSString *licensesUrl = @"licenses";
NSString *statesUrl = @"states";
NSString *dealershipsUrl = @"dealerships";
NSString *userExistsUrl = @"userExists";
NSString *contactInfoUrl = @"contactinfo";
NSString *licenseImageUrl = @"licenseimage";
NSString *stateQuestionsUrl = @"statequestions";
NSString *saveImageUrl = @"saveImageUrl";
NSString *confirmUserUrl = @"userExists";

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
        blockingRequestRunning = false;
        currentUniqueTag = 1000;
        dataFromConnectionByTag = [[NSMutableDictionary alloc] init];
        connections = [[NSMutableDictionary alloc] init];
        licenses = [[NSMutableArray alloc] init];
        
        connectionNumber = [NSDecimalNumber zero];
        typeLicenses = [[NSDecimalNumber alloc] initWithInt:1];
        typeOther = [[NSDecimalNumber alloc] initWithInt:2];
        typeUserExists = [[NSDecimalNumber alloc] initWithInt:3];
        typeDealerships = [[NSDecimalNumber alloc] initWithInt:4];
        typeContactInfo = [[NSDecimalNumber alloc] initWithInt:5];
        typeLicenseImage = [[NSDecimalNumber alloc] initWithInt:6];
        typeStateQuestions = [[NSDecimalNumber alloc] initWithInt:7];
        typeStates = [[NSDecimalNumber alloc] initWithInt:8];
        typeSubmitContactInfo = [[NSDecimalNumber alloc] initWithInt:9];
        typeSubmitLicense = [[NSDecimalNumber alloc] initWithInt:10];
        typeSubmitNewUser = [[NSDecimalNumber alloc] initWithInt:11];
        typeSubmitImageData = [[NSDecimalNumber alloc] initWithInt:12];
        typeConfirmUser = [[NSDecimalNumber alloc] initWithInt:13];
        
        NSLog(@"going to confirm user");
        [self confirmUser];
    }
    return self;
}

-(NSInteger)getAUniqueTag{
    currentUniqueTag++;
    return currentUniqueTag;
}


#pragma mark - Put Functions

//Post function
-(void)makeRequestWithVerb:(NSString *)verb forUrl:(NSURL *)url body:(NSDictionary *)bodyData forType:(NSNumber *)type finalDelegate:(id)delegate{
    NSLog(@"making post request, %@", bodyData);
    NSError *error = nil;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:verb];
    if(bodyData){
        NSData *postData = [NSJSONSerialization dataWithJSONObject:bodyData options:0 error:&error];
        [req setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody:postData];
    }
    if (error != nil) {
        NSLog(@"make post reuqest error: %@", error);
    }else{
        [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:type body:nil delegate:delegate]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

-(void)confirmUser{
    NSLog(@"confirming user");
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, confirmUserUrl]];
    User *user = [[User alloc] init];
    user.deviceType = 1;
    
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[User dictionaryFromUser:user] forType:typeConfirmUser finalDelegate:self];
}

-(void)putImage:(NSData *)bodyData forDelegate:(id)delegate{
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, saveImageUrl]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"PUT"];
    if(bodyData){
        [req setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
        [req setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody:bodyData];
    }
    if(error)
        NSLog(@"%@", error);
    else{
        [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeSubmitImageData body:nil delegate:delegate]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

-(void)putLicense:(License *)license forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[License dictionaryFromLicense:license] forType:typeSubmitLicense finalDelegate:delegate];
}

-(void)putContactInfo:(ContactInfo *)contactInfo forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[ContactInfo dictionaryFromContactInfo:contactInfo] forType:typeSubmitLicense finalDelegate:delegate];
}


#pragma mark - Delete Functions

-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id)delegate{
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, saveImageUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"DELETE"];
    if(error)
        NSLog(@"%@", error);
    else{
        [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeSubmitImageData body:nil delegate:delegate]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}



#pragma mark - Get Functions

-(void)genericGetFunctionForDelegate:(id)delegate forSpecificUrlString:(NSString *)urlPiece forType:(NSNumber *)type{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, urlPiece]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:type body:nil delegate:delegate]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getLicensesForDelegate:(id)delegate{
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:licensesUrl forType:typeLicenses];
}

-(void)getStates:(id)delegate{
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:statesUrl forType:typeStates];
}

-(void)getDealerships:(id)delegate{
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:dealershipsUrl forType:typeDealerships];
}

-(void)getUserExists:(id)delegate{
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:userExistsUrl forType:typeUserExists];
}
//- (NSURL *)URLByAppendingQueryStringKey:(NSString *)queryStringKey value:(NSString *)queryStringValue
-(void)getContactInfoByContactInfoId:(NSInteger)contactInfoId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    url = [url URLByAppendingQueryStringKey:@"contactinfoid" value:[NSString stringWithFormat:@"%ld", (long)contactInfoId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeContactInfo body:nil delegate:delegate]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getContactInfoByLicenseId:(NSInteger)licenseId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeContactInfo body:nil delegate:delegate]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getLicenseImageForLicenseId:(NSInteger)licenseId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licenseImageUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeLicenseImage body:nil delegate:delegate]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getStateQuestionsForStateId:(NSInteger)stateId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, stateQuestionsUrl]];
    url = [url URLByAppendingQueryStringKey:@"stateid" value:[NSString stringWithFormat:@"%ld", (long)stateId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeStateQuestions body:nil delegate:delegate]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}


#pragma mark - Fetch Queue

-(void)doFetchQueue{
    NSLog(@"doing fetch queue");
    if (!tryingToAuthenticate && !blockingRequestRunning && callQueue.count != 0) {
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
    NSLog(@"doing request");
    if (self.auth == nil) {
        NSLog(@"auth is nil");
        [self showGoogleLogin:cq.delegate];
    }else{
        cq.alreadySent = true;
        if ([cq.type isEqualToNumber:typeConfirmUser]) {
            blockingRequestRunning = true;
            NSLog(@"doing blocking request");
        }
        [self.auth authorizeRequest:cq.request completionHandler:^(NSError *error) {
            if (error == nil) {// success
                NSLog(@"auth authorized");
                tryingToAuthenticate = false;
                [cq.request setValue:@"google" forHTTPHeaderField:@"Authprovider"];
                [connections setObject:[[NSURLConnectionWithTag alloc]initWithRequest:cq.request delegate:self startImmediately:YES typeTag:cq.type uniqueTag:connectionNumber finalDelegate:cq.delegate] forKey:connectionNumber];
                [connectionNumber decimalNumberByAdding:[NSDecimalNumber one]];
                [self doFetchQueue];
            }else{
                NSLog(@"failed to authorize request, %@", error.localizedDescription);
                if (![self.auth canAuthorize]) {
                    NSLog(@"auth cannot authorize");
                }
                cq.alreadySent = false;
                [self showGoogleLogin:cq.delegate];
            }
        }];
    }
}

#pragma mark - Connection Handling
-(void)connection:(NSURLConnectionWithTag *)connection didReceiveData:(NSData *)data{
    NSLog(@"saving data for unique tag: %@", connection.uniqueTag);
    if ([dataFromConnectionByTag objectForKey:connection.uniqueTag] == nil) {
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        [dataFromConnectionByTag setObject:newData forKey:connection.uniqueTag];
        return;
    }else{
        [[dataFromConnectionByTag objectForKey:connection.uniqueTag] appendData:data];
    }
}

- (void) connection:(NSURLConnectionWithTag *)connection didReceiveResponse:(NSURLResponse *)response{
    if([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int status = [httpResponse statusCode];
        if ([connection.typeTag isEqualToNumber:typeUserExists]) {
            if (status == 403) {
                NSLog(@"recieved status unauthorized for typeUserExists");
                [connection cancel];
                if ([connection.finalDelegate respondsToSelector:@selector(showThisModal:)]) {
                    NewUserModalViewController *rootViewController = [[NewUserModalViewController alloc] initWithNibName:nil bundle:nil];
                    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                    [connection.finalDelegate performSelector:@selector(showThisModal:) withObject:viewController];
                }else
                    NSLog(@"cant load new user modal");
            }
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnectionWithTag *)conn{
    NSError *e = nil;
    NSLog(@"%@", typeLicenses);
    if ([dataFromConnectionByTag objectForKey:conn.uniqueTag]) {
        if ([conn.typeTag isEqualToNumber:typeLicenses] || [conn.typeTag isEqualToNumber:typeSubmitLicense]) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"made json array");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
            }else if ([conn.finalDelegate respondsToSelector:@selector(licenses:)]) {
                NSLog(@"responds to selector");
                NSArray *licenses1 = [License parseJsonArray:jsonArray];
                NSLog(@"parsed licenses: %ld", (long)licenses1.count);
                [conn.finalDelegate performSelector:@selector(licenses:) withObject:licenses1];
            }else
                NSLog(@"cannot send licenses to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeOther]){// history, code, attributes
            // parse and return
            
        }else if([conn.typeTag isEqualToNumber:typeUserExists] || [conn.typeTag isEqualToNumber:typeSubmitNewUser] || [conn.typeTag isEqualToNumber:typeConfirmUser]){
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got user");
            if (e != nil) {
                NSLog(@"error deserializing json object, %@", e.localizedDescription);
            }else if ([conn.typeTag isEqualToNumber:typeConfirmUser]) {
                blockingRequestRunning = false;
                NSLog(@"unblocking requests");
                NSLog(@"%@", d);
            }else if([conn.finalDelegate respondsToSelector:@selector(user:)]){
                NSLog(@"responds to selector: user");
                User *user = [[User alloc] initWithDictionary:d];
                [conn.finalDelegate performSelector:@selector(user:) withObject:user];
            }else
                NSLog(@"cant respond to selector user:");
            
        }else if([conn.typeTag isEqualToNumber:typeStates]){
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got states");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
            }else if ([conn.finalDelegate respondsToSelector:@selector(states:)]) {
                NSLog(@"responds to selector");
                NSArray *states = [State parseJsonArray:jsonArray];
                NSLog(@"parsed states");
                [conn.finalDelegate performSelector:@selector(states:) withObject:states];
            }else
                NSLog(@"cannot send licenses to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeDealerships]){
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got dealerships");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
            }else if ([conn.finalDelegate respondsToSelector:@selector(dealerships:)]) {
                NSLog(@"responds to selector");
                NSArray *dealerships = [Dealership parseJsonArray:jsonArray];
                NSLog(@"parsed dealerships");
                [conn.finalDelegate performSelector:@selector(dealerships:) withObject:dealerships];
            }else
                NSLog(@"cannot send licenses to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeContactInfo] || [conn.typeTag isEqualToNumber:typeSubmitContactInfo]){
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got contact info");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
            }else if ([conn.finalDelegate respondsToSelector:@selector(contactInfo:)]) {
                NSLog(@"responds to selector");
                ContactInfo *contactInfo = [[ContactInfo alloc] initWithDictionary:d];
                NSLog(@"parsed licenses");
                [conn.finalDelegate performSelector:@selector(contactInfo:) withObject:contactInfo];
            }else
                NSLog(@"cannot send licenses to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeLicenseImage]){
            
        }else if([conn.typeTag isEqualToNumber:typeStateQuestions]){
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got state questions, %@", jsonArray);
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
            }else if ([conn.finalDelegate respondsToSelector:@selector(stateQuestions:)]) {
                NSLog(@"responds to selector");
                NSArray *array = [StateQuestions parseJsonArray:jsonArray];
                NSLog(@"parsed stateQuestions: %ld", (long)array.count);
                [conn.finalDelegate performSelector:@selector(stateQuestions:) withObject:array];
            }else
                NSLog(@"cannot send licenses to delegate");
        }
    }else
        NSLog(@"couldnt find data for typeTag: %@, uniqueTag: %@", conn.typeTag, conn.uniqueTag);
    
    // clean up
    [dataFromConnectionByTag removeObjectForKey:conn.uniqueTag]; // after done using the data, remove it
    [connections removeObjectForKey:conn.uniqueTag];// remove the connection
    [self doFetchQueue];
}

-(void)connection:(NSURLConnectionWithTag *)conn didFailWithError:(NSError *)error{
    NSString *errorString = [NSString stringWithFormat:@"Fetch  failed for url: %@, error: %@", conn.originalRequest.URL.absoluteString, [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}


#pragma mark - Google oauth2 stuff

-(void)showGoogleLogin:(id)delegate{
    NSLog(@"going to show google login");
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:self.scope
                                                                clientID:self.kMyClientID
                                                            clientSecret:self.kMyClientSecret
                                                        keychainItemName:self.kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if ([delegate respondsToSelector:@selector(showThisModal:)]) {
        [delegate showThisModal:navController];
    }else
        NSLog(@"delegate cant show view controller for google login");
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
        self.auth.shouldAuthorizeAllRequests = true;
        NSLog(@"got authentication back, success");
        if (![auth canAuthorize]) {
            NSLog(@"error, came back but cant authorize, never should happen");
        }
        tryingToAuthenticate = false;
        [self doFetchQueue];
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
//    [self signOutOfGoogle];
    auth.shouldAuthorizeAllRequests = true;
    // We can determine later if the auth object contains an access token by calling its -canAuthorize method
    if (![auth canAuthorize]) {
        NSLog(@"auth cannot authorize");
        [self showGoogleLogin:delegate];
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








































