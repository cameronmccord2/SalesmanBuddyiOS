//
//  MTCAuthManager.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/26/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "MTCAuthManager.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "NSURLConnectionWithTag.h"
#import "MTCUser.h"

@implementation MTCAuthManager


+(MTCAuthManager *)sharedManager{
    static MTCAuthManager *sharedManager;
    @synchronized(self){// this is if multiple threads do this at the exact same time
        if (!sharedManager) {
            sharedManager = [[MTCAuthManager alloc] init];
        }
        return sharedManager;
    }
}

-(id)init{
    self = [super init];
    if (self) {
        self.scopes = [[NSMutableSet alloc] init];
        
        // You customize here
        
//        self.kKeychainItemName = @"VocabGameKeyV0";
//        self.kClientID = @"c44e37ef-cb01-4d27-a058-8aac52898e13";
//        self.kClientSecret = @"4405b1fb-cbe6-4686-ab8e-06c9f7dd502b";
//        // End customization
//        [self addScope:@"https://api.mtc.byu.edu/auth"];// required scope
        
        
        
        // SalesmanBuddy
        self.kKeychainItemName = @"SalesmanCompanionKeyV1";  // if nil, then the user has to sign in every time the application runs
        self.kClientID = @"38235450166-dgbh1m7aaab7kopia2upsdj314odp8fc.apps.googleusercontent.com";     // pre-assigned by service
        self.kClientSecret = @"zC738ZbMHopT2C1cyKiKDBQ6"; // pre-assigned by service
        [self addScope:@"https://www.googleapis.com/auth/plus.me"];// scope for Google+ API
        
        
        
        

        self.error = @"";
        
        self.user = nil;
        
        connectionNumber = [NSDecimalNumber zero];
        typeGetUser = [[NSDecimalNumber alloc] initWithInt:1];
        
        dataFromConnectionByTag = [[NSMutableDictionary alloc] init];
        connections = [[NSMutableDictionary alloc] init];
        
//        connectionNumber = [NSDecimalNumber zero];
//        typeLicenses = [[NSDecimalNumber alloc] initWithInt:1];
        
        NSLog(@"going to confirm user");
//        [self getUserForDelegate:self];
    }
    return self;
}

-(void)addScope:(NSString *)scope{
    [self.scopes addObject:scope];
}

-(NSString *)spaceDelimitedScope{
    NSMutableString *scope = [[NSMutableString alloc] init];
    int count = 0;
    for (NSString *s in self.scopes) {
        count++;
        [scope appendString:s];
        if (count != self.scopes.count) {
            [scope appendString:@" "];
        }
    }
    return scope;
}

-(BOOL)authorizeRequest:(NSMutableURLRequest *)request delegate:(id)delegate{
    if (self.auth == nil) {
        // cache the request so that we can do it once we are authenticated, force all other authorization requests into the queue too
        [self login:delegate];// this part is broken because it is async******************************************************
        return false;
    }else
        return [self.auth authorizeRequest:request];
}

-(void)authorizeRequest:(NSMutableURLRequest *)request delegate:(id)delegate didFinishSelector:(SEL)sel{
    if (self.auth == nil) {
        // cache the request so that we can do it once we are authenticated, force all other authorization requests into the queue too
        [self login:delegate];
    }else
        [self.auth authorizeRequest:request delegate:delegate didFinishSelector:sel];
}

-(void)authorizeRequest:(NSMutableURLRequest *)request delegate:(id)delegate completionHandler:(void (^)(NSError *))handler{
    if (self.auth == nil) {
        // cache the request so that we can do it once we are authenticated, force all other authorization requests into the queue too
        [self login:delegate];
    }else
        [self.auth authorizeRequest:request completionHandler:handler];
}

-(BOOL)canAuthorize{
    if (self.auth == nil) {
        return false;
    }else
        return [self.auth canAuthorize];
}



#pragma mark - Get User Functions

-(void)getUserForDelegate:(id)delegate{
    NSString *userUrl = @"https://api.mtc.byu.edu/auth/v1/users/me";// add token here
}

















#pragma mark - Auth stuff

-(GTMOAuth2Authentication *)makeAuth{
    
    // MTC OAuth2
    static NSString *redirectURI = @"https://mtc.byu.edu/OAuthCallback";
    // The controller will watch for the server to redirect the web view to this URI, but this URI will not be loaded, so it need not be for any actual web page.
    
    NSURL *tokenURL = [NSURL URLWithString:@"https://auth.mtc.byu.edu/oauth2/auth"];
    static NSString *serviceName = @"MTCAuthService";
    return [GTMOAuth2Authentication authenticationWithServiceProvider:serviceName
                                                             tokenURL:tokenURL
                                                          redirectURI:redirectURI
                                                             clientID:self.kClientID
                                                         clientSecret:self.kClientSecret];
    
    //        // Google oauth2
    //        return [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:self.kKeychainItemName
    //                                                                     clientID:self.kMyClientID
    //                                                                 clientSecret:self.kMyClientSecret];
}

-(void)login:(id)delegate{
    NSLog(@"going to show login");
    
    if(self.auth == nil)
        self.auth = [self makeAuth];
    if ([self.auth canAuthorize]) {
        [self viewController:nil finishedWithAuth:self.auth error:nil];// got good auth from the keychain so just keep going
        return;
    }
    
    // MTC
    NSURL *authURL = [NSURL URLWithString:@"https://auth.mtc.byu.edu/oauth2/auth"];
    self.auth.scope = [self spaceDelimitedScope];
    GTMOAuth2ViewControllerTouch *viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:self.auth
                                                                  authorizationURL:authURL
                                                                  keychainItemName:self.kKeychainItemName
                                                                          delegate:self
                                                                  finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    
//    // Google 
//    GTMOAuth2ViewControllerTouch *viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:[self spaceDelimitedScope]
//                                                                clientID:self.kClientID
//                                                            clientSecret:self.kClientSecret
//                                                        keychainItemName:self.kKeychainItemName  // if nil, then the user has to sign in every time the application runs
//                                                                delegate:self
//                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    
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
    if (error != nil) {
        NSLog(@"%ld", (long)error.code);
        if (error.code == -1000) {
            NSLog(@"User closed the login modal before authenticating");
            if ([self.conrollerResponsibleForGoogleLogin respondsToSelector:@selector(userCanceledLogin)]) {
                [self.conrollerResponsibleForGoogleLogin performSelector:@selector(userCanceledLogin) withObject:viewController];
            }
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
        }else
            NSLog(@"delegate cant do dismissAuthModal:");
        [self doFetchQueue];
    }
}



//-(void)makeAuthViableAndExecuteCallQueue:(id)delegate{
//    GTMOAuth2Authentication *auth;
//    if (self.auth == nil) {
//        NSLog(@"getting auth from keychain");
//        auth = [self makeAuth];
//    }else
//        auth = self.auth;
//    
//    auth.shouldAuthorizeAllRequests = true;
//    // We can determine later if the auth object contains an access token by calling its -canAuthorize method
//    if (![auth canAuthorize]) {
//        NSLog(@"auth cannot authorize");
//        [self login:delegate];
//    }else{
//        NSLog(@"auth can authorize");
//        self.auth = auth;
//        [self doFetchQueue];
//    }
//}

-(void)signOut{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.kKeychainItemName];
    
    // MTC
    
    
//    // Google
//    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}







































#pragma mark - Connection Handling

-(void)connection:(NSURLConnectionWithTag *)connection didReceiveData:(NSData *)data{
    if ([dataFromConnectionByTag objectForKey:connection.uniqueTag] == nil) {
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        [dataFromConnectionByTag setObject:newData forKey:connection.uniqueTag];
        return;
    }else
        [[dataFromConnectionByTag objectForKey:connection.uniqueTag] appendData:data];
}

- (void) connection:(NSURLConnectionWithTag *)connection didReceiveResponse:(NSURLResponse *)response{
    if([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int status = [httpResponse statusCode];
        if ([connection.typeTag isEqualToNumber:typeGetUser]) {
            if (status == 403) {
                NSLog(@"recieved status unauthorized for typeGetUser");
                [connection cancel];
            }
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnectionWithTag *)conn{
    NSError *e = nil;
    if ([dataFromConnectionByTag objectForKey:conn.uniqueTag]) {
        if([conn.typeTag isEqualToNumber:typeGetUser]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got user");
            if (e != nil) {
                NSLog(@"error deserializing json object, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if([conn.finalDelegate respondsToSelector:@selector(gotUser:)]){
                NSLog(@"responds to selector: gotUser");
                self.user = [[MTCUser alloc] initWithDictionary:d];
                [conn.finalDelegate performSelector:@selector(gotUser:) withObject:self.user];
            }else
                NSLog(@"cant respond to selector finishedSubmitLicense:");
        }else
            NSLog(@"type not accounted for: %@", conn.typeTag);
    }else
        NSLog(@"couldnt find data for typeTag: %@, uniqueTag: %@", conn.typeTag, conn.uniqueTag);
    
    // clean up
    [dataFromConnectionByTag removeObjectForKey:conn.uniqueTag]; // after done using the data, remove it
    [connections removeObjectForKey:conn.uniqueTag];// remove the connection
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    self.error = [NSString stringWithFormat:@"%@, %@", self.error, string];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"error: %@", self.error);
    self.error = @"";
}

-(void)connection:(NSURLConnectionWithTag *)conn didFailWithError:(NSError *)error{
    NSString *errorString = [NSString stringWithFormat:@"Fetch  failed for url: %@, error: %@", conn.originalRequest.URL.absoluteString, [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}



@end
