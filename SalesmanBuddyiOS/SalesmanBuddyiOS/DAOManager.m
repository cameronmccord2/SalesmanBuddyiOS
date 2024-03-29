//
//  DAOManager.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 10/17/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "DAOManager.h"
#import "User.h"


@implementation DAOManager
// implement:
// {cache:true}


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
        self.scope = @"";
        self.error = @"";
        callQueue = [[NSMutableArray alloc] init];
        tryingToAuthenticate = false;
        blockingRequestRunning = false;
        dataFromConnectionByTag = [[NSMutableDictionary alloc] init];
        connections = [[NSMutableDictionary alloc] init];
        connectionNumber = [NSDecimalNumber zero];
        self.userConfirmed = false;
    }
    return self;
}

enum{
    Junk = 0, ConfirmUserType = 1, StoreType = 5, NormalType = 9
};

-(NSDecimalNumber *)getConnectionNumber{
    connectionNumber = [connectionNumber decimalNumberByAdding:[NSDecimalNumber one]];
    return connectionNumber;
}

-(void)addAuthScope:(NSString *)newScope{
    if (self.scope.length > 0)
        self.scope = [NSString stringWithFormat:@"%@ ", self.scope];// add a space
    self.scope = [NSString stringWithFormat:@"%@%@", self.scope, newScope];
}



#pragma mark - Block Templates

-(void (^)(NSData *, NSError *, void(^)()))errorTemplateForDelegate:(id)delegate selectorOnError:(SEL)errorSelector{
    
    void(^error)(NSData *, NSError *, void(^)()) = ^void(NSData *data, NSError *error, void(^cleanUp)()){
        if (error == nil) {
            NSLog(@"error was nil in error template, this shouldnt ever happen");
        }
        if (errorSelector == nil) {
            NSLog(@"There was no error selector specified for delegate: %@. This error template function doesn't do anything without a selector.", delegate);
            return;
        }
        
        if ([delegate respondsToSelector:errorSelector]) {
            NSLog(@"responds to selector %@", NSStringFromSelector(errorSelector));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:errorSelector withObject:data withObject:error];
#pragma clang diagnostic pop
        }else
            NSLog(@"cannot send selector: %@ to delegate %@", NSStringFromSelector(errorSelector), NSStringFromClass([delegate class]));
        cleanUp();
    };
    return error;
}


-(void (^)(NSData *, NSURLConnectionWithExtras *, NSProgress *))thenTemplateForDelegate:(id)delegate selectorOnThen:(SEL)thenSelector{
    void(^then)(NSData *, NSURLConnectionWithExtras *, NSProgress *) = ^void(NSData *data, NSURLConnectionWithExtras *connection, NSProgress *nsProgress){
        if (delegate == nil) {
            NSLog(@"delegate is nil in thenTemplateForDelegate, dont do anything");
            return;
        }
        if (thenSelector == nil) {
            NSLog(@"There was no then selector specified for the delegate: %@. This then template function doesn't do anything without a selector", NSStringFromClass([delegate class]));
            return;
        }
        if ([delegate respondsToSelector:thenSelector]) {
//            NSLog(@"responds to then selector: %@", NSStringFromSelector(thenSelector));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:thenSelector withObject:connection withObject:nsProgress];
#pragma clang diagnostic pop
        }else
            NSLog(@"Delegate %@ can't respond to the then selector: %@. The then selector needs to accept an %@ and %@", NSStringFromClass([delegate class]), NSStringFromSelector(thenSelector), NSStringFromClass([connection class]), NSStringFromClass([nsProgress class]));
    };
    return then;
}

-(void (^)(NSData *, void(^cleanUp)()))successTemplateForDelegate:(id)delegate selectorOnSuccess:(SEL)successSelector parseClass:(Class)parseClass resultIsArray:(BOOL)resultIsArray{
    
    SEL parseJsonArraySelector = @selector(arrayFromDictionaryList:);
    SEL initObjectWithDictionary = @selector(objectFromDictionary:);
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        if (resultIsArray) {
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//            NSLog(@"got Array");
//            NSLog(@"%@", jsonArray);
            if (e != nil) {
                [self doJsonError:data error:e];
            }else if ([delegate respondsToSelector:successSelector]) {
                NSLog(@"responds to success selector: %@", NSStringFromSelector(successSelector));
                if ([parseClass respondsToSelector:parseJsonArraySelector]) {
//                    NSLog(@"parseClass responds to selector: %@", NSStringFromSelector(parseJsonArraySelector));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    NSArray *array = [parseClass performSelector:parseJsonArraySelector withObject:jsonArray];
//                    NSLog(@"parsed list");
                    [delegate performSelector:successSelector withObject:array];
#pragma clang diagnostic pop
                }else
                    NSLog(@"parseClass cannot respond to %@, class: %@", NSStringFromSelector(parseJsonArraySelector), parseClass);
            }else
                NSLog(@"cannot send list to delegate: %@, doesnt repond to the specified successSelector: %@", NSStringFromClass([delegate class]), NSStringFromSelector(successSelector));
        }else{
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//            NSLog(@"got Dictionary");
            if (e != nil) {
                [self doJsonError:data error:e];
            }else if ([delegate respondsToSelector:successSelector]) {
                NSLog(@"responds to success selector: %@", NSStringFromSelector(successSelector));
                if ([parseClass respondsToSelector:initObjectWithDictionary]) {
//                    NSLog(@"parseClass responds to selector: %@", NSStringFromSelector(initObjectWithDictionary));
//                    NSLog(@"%@", d);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [delegate performSelector:successSelector withObject:[parseClass performSelector:initObjectWithDictionary withObject:d]];
#pragma clang diagnostic pop
                }else
                    NSLog(@"parseClass: %@, cant respond to selector: %@", NSStringFromClass([parseClass class]), NSStringFromSelector(initObjectWithDictionary));
            }else
                NSLog(@"cannot send result to delegate %@", NSStringFromClass([delegate class]));
        }
        cleanUp();
    };
    return success;
}



#pragma mark - Generic Functions

-(void)makeRequestWithVerb:(NSString *)verb forUrl:(NSString *)url bodyDictionary:(NSDictionary *)bodyDictionary bodyData:(NSData *)bodyData authDelegate:(id<DAOManagerDelegateProtocol>)delegate contentType:(NSString *)contentType requestType:(NSInteger)type success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *, NSURLConnectionWithExtras *, NSProgress *))then{
    
    NSLog(@"making %@ request to url:%@, by: %@", verb, url, NSStringFromClass([delegate class]));
    NSError *e = nil;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [req setHTTPMethod:verb];
    
    [self addBodyDataToRequest:req bodyDictionary:bodyDictionary bodyData:bodyData contentType:contentType error:&e];
    
    if (e != nil) {
        NSLog(@"make post reuqest error: %@", e.localizedDescription);
    }else{
        [callQueue addObject:[CallQueue initWithRequest:req authDelegate:delegate requestType:type success:success error:error then:then]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

-(void)addBodyDataToRequest:(NSMutableURLRequest *)req bodyDictionary:(NSDictionary *)bodyDictionary bodyData:(NSData *)bodyData contentType:(NSString *)contentType error:(NSError *__autoreleasing *)e{
    
    if(bodyData != nil && bodyDictionary != nil)
        NSLog(@"Warning! You defined body data and body dictionary. The dictionary-->data will replace the data you specified");
    
    if(bodyDictionary)
        bodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:e];
    
    if(bodyData){
        [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
        if (contentType == nil) {
            NSLog(@"content type was nil, setting to default of application/json");
            contentType = @"application/json";
        }
        
        [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody:bodyData];
    }
}

-(void)genericGetFunctionForDelegate:(id<DAOManagerDelegateProtocol>)delegate forUrl:(NSString *)url requestType:(NSInteger)type success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *, NSURLConnectionWithExtras *, NSProgress *))then{
    
    NSLog(@"making GET request to url:%@, by: %@", url, NSStringFromClass([delegate class]));
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [callQueue addObject:[CallQueue initWithRequest:req authDelegate:delegate requestType:(NSInteger)type success:success error:error then:then]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)genericListGetForDelegate:(id)delegate url:(NSString *)url selector:(SEL)selector parseClass:(Class)parseClass requestType:(NSInteger)type{
    [self genericGetFunctionForDelegate:delegate forUrl:url requestType:type success:[self successTemplateForDelegate:delegate selectorOnSuccess:selector parseClass:parseClass resultIsArray:YES] error:nil then:nil];
}

-(void)genericObjectGetForDelegate:(id)delegate url:(NSString *)url selector:(SEL)selector parseClass:(Class)parseClass requestType:(NSInteger)type{
    [self genericGetFunctionForDelegate:delegate forUrl:url requestType:type success:[self successTemplateForDelegate:delegate selectorOnSuccess:selector parseClass:parseClass resultIsArray:NO] error:nil then:nil];
}


#pragma mark - Fetch Queue

-(void)runRequestQueue{
    [self doFetchQueue];
}

-(void)doFetchQueue{
//    NSLog(@"doing fetch queue");
    for (int i = 0; i < 10; i++) {// loop through all the priorities
        for (CallQueue *cq in callQueue) {
            if(!tryingToAuthenticate && !blockingRequestRunning){
                if (!cq.alreadySent && cq.type == i) {
                    if(i < 6)// everything under 6 is a blocking request priority
                        blockingRequestRunning = YES;
                    [self doRequest:cq];
                    return;
                }
            }else
                return;
        }
    }
}

-(void)fetchQueueTimerFinish{
    blockingRequestRunning = false;
    [self runRequestQueue];
}

// Initialize Connection
-(void)doRequest:(CallQueue *)cq{
//    NSLog(@"doing request");
    if (self.auth == nil) {
        NSLog(@"auth is nil, show login");
        [self showGoogleLogin:cq.delegate];
    }else{
//        NSLog(@"trying to authorize");
        cq.alreadySent = true;
        
        [self.auth authorizeRequest:cq.request completionHandler:^(NSError *error) {
//            NSLog(@"%@",[self.auth refreshToken]);
            if (error == nil) {// success
//                NSLog(@"%@", [cq.request allHTTPHeaderFields]);
//                NSLog(@"auth authorized");
                tryingToAuthenticate = false;
                
                if(cq.type == ConfirmUserType){
                    NSLog(@"adding user to request");
                    if(self.auth.refreshToken == nil){
                        NSLog(@"big problem, there is no refresh token");
                    }else{
                        User *user = [User userWithRefreshToken:self.auth.refreshToken];
                        NSDictionary *userDictionary = [User dictionaryFromUser:user];
                        NSLog(@"%@", userDictionary);
                        [self addBodyDataToRequest:cq.request bodyDictionary:userDictionary  bodyData:nil contentType:nil error:&error];
                        if(error)
                            NSLog(@"error with sending refresh token: %@", error);
                    }
                }
                
                [cq.request setValue:@"google" forHTTPHeaderField:@"Authprovider"];
                
                NSURLConnectionWithExtras *connectionObject = [NSURLConnectionWithExtras connectionWithRequest:cq.request delegate:self startImmediately:YES uniqueTag:[self getConnectionNumber] finalDelegate:cq.delegate success:cq.success error:cq.error then:cq.then];
                [connections setObject:connectionObject forKey:connectionNumber];
                
                
                [self doThenWithData:nil connection:connectionObject];// hand back the connection object so it can be canceled if desired
                
                [self doFetchQueue];
            }else{
                NSLog(@"failed to authorize request, %@", error.localizedDescription);
                NSLog(@"errorCode: %ld", (long)error.code);
                cq.alreadySent = false;
                switch (error.code) {
                    case -1009:
                        NSLog(@"Cant connect to the internet");
                        blockingRequestRunning = true;
                        [self.timers addObject:[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(fetchQueueTimerFinish) userInfo:nil repeats:NO]];
                        break;
                        
                    case -1000:
                        NSLog(@"User closed the login modal before logging in");
                    default:
                        if (![self.auth canAuthorize]) {
                            NSLog(@"auth cannot authorize");
                            [self showGoogleLogin:cq.delegate];
                        }else{
                            NSLog(@"trying again imediately");
                            [self doRequest:cq];
                        }
                        break;
                }
            }
        }];
    }
}

-(void)doJsonError:(NSData *)data error:(NSError *)error{
    NSLog(@"error deserializing json array, %@", error.localizedDescription);
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSXMLParser *p = [[NSXMLParser alloc] initWithData:data];
    [p setDelegate:self];
    [p parse];
}


#pragma mark - Execute block convenience functions

-(void)doThenWithData:(NSData *)data connection:(NSURLConnectionWithExtras *)connection{
    if (connection.then != nil) {
        connection.then(data, connection, connection.nsProgress);
    }
}

-(void)doErrorWithData:(NSData *)data error:(NSError *)error forConnection:(NSURLConnectionWithExtras *)connection{
    if (data == nil) {
        data = [dataFromConnectionByTag objectForKey:connection.uniqueTag];
    }
    void (^cleanUp)() = ^void(){
        [dataFromConnectionByTag removeObjectForKey:connection.uniqueTag]; // after done using the data, remove it
        [connections removeObjectForKey:connection.uniqueTag];// remove the connection
        [self doFetchQueue];
    };
    
    if (connection.error != nil) {
        connection.error(data, error, cleanUp);
    }
}

#pragma mark - Connection Handling
-(void)connection:(NSURLConnectionWithExtras *)connection didReceiveData:(NSData *)data{
    //    NSLog(@"saving data for unique tag: %@", connection.uniqueTag);
    
    if ([dataFromConnectionByTag objectForKey:connection.uniqueTag] == nil) {
        NSLog(@"created new connection data for tag: %@, url: %@", connection.uniqueTag, connection.originalRequest.URL);
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        [dataFromConnectionByTag setObject:newData forKey:connection.uniqueTag];
        connection.nsProgress.completedUnitCount = data.length;// first time
        return;
    }else{
//        NSLog(@"saving data for connection tag: %@, url: %@", connection.uniqueTag, connection.originalRequest.URL);
        [[dataFromConnectionByTag objectForKey:connection.uniqueTag] appendData:data];
        connection.nsProgress.completedUnitCount += data.length;
        [self doThenWithData:[dataFromConnectionByTag objectForKey:connection.uniqueTag] connection:connection];
    }
}

- (void)connection:(NSURLConnectionWithExtras *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{// for upload progress
    connection.nsProgress.totalUnitCount = totalBytesExpectedToWrite;
    connection.nsProgress.completedUnitCount = totalBytesWritten;
    [self doThenWithData:[[NSData alloc] init] connection:connection];
}

- (void) connection:(NSURLConnectionWithExtras *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"did recieve response");
    if([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        [connection setStatusCodeForNow:[httpResponse statusCode]];
        //        if ([connection.typeTag isEqualToNumber:typeUserExists]) {
        //            if (status == 403) {
        //                NSLog(@"recieved status unauthorized for typeUserExists");
        //                [connection cancel];
        //                if ([connection.finalDelegate respondsToSelector:@selector(showAuthModal:)]) {
        //                    NewUserModalViewController *rootViewController = [[NewUserModalViewController alloc] initWithNibName:nil bundle:nil];
        //                    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        //                    [connection.finalDelegate performSelector:@selector(showAuthModal:) withObject:viewController];
        //                }else
        //                    NSLog(@"cant load new user modal");
        //            }
        //        }
        
        // NSProgress
        connection.nsProgress.totalUnitCount = response.expectedContentLength;
        [self doThenWithData:[dataFromConnectionByTag objectForKey:connection.uniqueTag] connection:connection];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnectionWithExtras *)connection{
    NSLog(@"connection did finish loading");
    
    void (^cleanUp)() = ^void(){
        NSLog(@"connection finished for tag: %@, url: %@", connection.uniqueTag, connection.originalRequest.URL);
        [dataFromConnectionByTag removeObjectForKey:connection.uniqueTag]; // after done using the data, remove it
        [connections removeObjectForKey:connection.uniqueTag];// remove the connection
        [self doFetchQueue];
    };
    
    NSData *data = [dataFromConnectionByTag objectForKey:connection.uniqueTag];
    
    if (connection.success != nil) {
        connection.success(data, cleanUp);
    }
    if (connection.then != nil) {
        connection.nsProgress.completedUnitCount = connection.nsProgress.totalUnitCount;
        connection.then(data, connection, connection.nsProgress);
    }
}

-(void)connection:(NSURLConnectionWithExtras *)conn didFailWithError:(NSError *)error{
    [self doErrorWithData:nil error:error forConnection:conn];
    
    // DO A GLOBAL ERROR HANDLER FOR NOW FOR MY DAO
    
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed for url: %@, error: %@", conn.originalRequest.URL.absoluteString, [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

#pragma mark - XML Parser error functions

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    self.error = [NSString stringWithFormat:@"error%@, %@", self.error, string];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"error: %@", self.error);
    self.error = @"";
}






#pragma mark - Google oauth2 stuffd

-(void)showGoogleLogin:(id)delegate{
    NSLog(@"going to show google login");
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:self.scope
                                                                clientID:self.kMyClientID
                                                            clientSecret:self.kMyClientSecret
                                                        keychainItemName:self.kKeychainItemName  // if nil, then the user has to sign in every time the application runs
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if ([delegate respondsToSelector:@selector(showAuthModal:)]) {
        self.conrollerResponsibleForGoogleLogin = delegate;
        [delegate showAuthModal:navController];
    }else
        NSLog(@"delegate cant show view controller for google login");
    // calls -(void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
}


-(void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"finished with auth");
    if (error != nil) {
        NSLog(@"%ld", (long)error.code);
        if (error.code == -1000) {
            NSLog(@"User closed the login modal before authenticating");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"You must be logged in to use this application." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }else
            NSLog(@"unsupported error code");
    } else {
        self.auth = auth;
        self.auth.shouldAuthorizeAllRequests = true;
        NSLog(@"got authentication back, success");
        if (![auth canAuthorize]) {
            NSLog(@"error, came back but cant authorize, never should happen");
        }
        if ([self.conrollerResponsibleForGoogleLogin respondsToSelector:@selector(dismissAuthModal:)]) {
            [self.conrollerResponsibleForGoogleLogin performSelector:@selector(dismissAuthModal:) withObject:viewController];
        }
        tryingToAuthenticate = false;
        [self doFetchQueue];
    }
}

-(void)makeAuthViableAndExecuteCallQueue:(id)delegate{
    NSLog(@"make auth viable and execute call queue");
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
//        NSLog(@"auth can authorize");
        self.auth = auth;
        [self doFetchQueue];
    }
}

-(void)signOut{
    NSLog(@"signing out");
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}


@end








































