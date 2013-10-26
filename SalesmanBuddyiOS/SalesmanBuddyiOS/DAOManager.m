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
NSString *saveImageUrl = @"savedata";
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
        self.error = @"";
        
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
        typeDeleteLicenseById = [[NSDecimalNumber alloc] initWithInt:14];
        typeSubmitLicenseUpdate = [[NSDecimalNumber alloc] initWithInt:15];
        
        NSLog(@"going to get the current location");
        [self getLocation];
        
        NSLog(@"going to confirm user");
        [self confirmUser];
    }
    return self;
}

-(NSInteger)getAUniqueTag{
    currentUniqueTag++;
    return currentUniqueTag;
}

-(User *)getUser{
    return self.user;
}

-(CLLocationCoordinate2D)getLocation{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    [locationManager stopUpdatingLocation];
    return coordinate;
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

-(void)putImage:(NSData *)bodyData forStateId:(NSInteger)stateId forDelegate:(id)delegate{
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, saveImageUrl]];
    url = [url URLByAppendingQueryStringKey:@"stateid" value:[NSString stringWithFormat:@"%ld", (long)stateId]];
    url = [url URLByAppendingQueryStringKey:@"base64" value:[NSString stringWithFormat:@"1"]];
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
        NSLog(@"putting image");
        [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeSubmitImageData body:nil delegate:delegate]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

-(void)putLicense:(License *)license forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    NSLog(@"%@", [License dictionaryFromLicense:license]);
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[License dictionaryFromLicense:license] forType:typeSubmitLicense finalDelegate:delegate];
}

-(void)putContactInfo:(ContactInfo *)contactInfo forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[ContactInfo dictionaryFromContactInfo:contactInfo] forType:typeSubmitLicense finalDelegate:delegate];
}


#pragma mark - Post Functions

-(void)updateLicense:(License *)license forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    NSLog(@"%@", [License dictionaryFromLicense:license]);
    [self makeRequestWithVerb:@"POST" forUrl:url body:[License dictionaryFromLicense:license] forType:typeSubmitLicenseUpdate finalDelegate:delegate];
}


#pragma mark - Delete Functions

-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id)delegate{
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"DELETE"];
    if(error)
        NSLog(@"%@", error);
    else{
        [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:typeDeleteLicenseById body:nil delegate:delegate]];
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
                cq.alreadySent = false;
                if (![self.auth canAuthorize]) {
                    NSLog(@"auth cannot authorize");
                    [self showGoogleLogin:cq.delegate];
                }else{
                    NSLog(@"trying again imediately");
                    [self doRequest:cq];
                }
            }
        }];
    }
}

#pragma mark - Connection Handling
-(void)connection:(NSURLConnectionWithTag *)connection didReceiveData:(NSData *)data{
    NSLog(@"saving data for unique tag: %@, typeTag: %@", connection.uniqueTag, connection.typeTag);
    if ([dataFromConnectionByTag objectForKey:connection.uniqueTag] == nil) {
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        [dataFromConnectionByTag setObject:newData forKey:connection.uniqueTag];
        return;
    }else{
        [[dataFromConnectionByTag objectForKey:connection.uniqueTag] appendData:data];
        if ([connection.typeTag isEqualToNumber:typeLicenseImage]) {
            connection.currentLength += data.length;
            if ([connection.finalDelegate respondsToSelector:@selector(connectionProgress:total:)]) {
                [connection.finalDelegate performSelector:@selector(connectionProgress:total:) withObject:@(connection.currentLength) withObject:@(connection.totalLength)];
            }else
                NSLog(@"cant execute selector connectionProgress:total:");
        }
    }
}

- (void)connection:(NSURLConnectionWithTag *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{// for upload progress
    if ([connection.typeTag isEqualToNumber:typeSubmitImageData]) {
        if ([connection.finalDelegate respondsToSelector:@selector(connectionProgress:total:)]) {
            [connection.finalDelegate performSelector:@selector(connectionProgress:total:) withObject:@(totalBytesWritten) withObject:@(totalBytesExpectedToWrite)];
        }else
            NSLog(@"cant perform selector connectionProgress:total:");
    }
}

// TODO cancel image download connections when going to main list
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
        }else if([connection.typeTag isEqualToNumber:typeLicenseImage]){// record total estimated content length for these types
            if (connection.totalLength == 0) {
                connection.totalLength = response.expectedContentLength;
            }
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnectionWithTag *)conn{
    NSError *e = nil;
    NSLog(@"%@", typeLicenses);
    if ([dataFromConnectionByTag objectForKey:conn.uniqueTag]) {
        if ([conn.typeTag isEqualToNumber:typeLicenses]) {
            NSLog(@"typeTag: %@", conn.typeTag);
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"made json array for licenses");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                NSXMLParser *p = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [p setDelegate:self];
                [p parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(licenses:)]) {
                NSLog(@"responds to selector licenses");
                NSMutableArray *licenses1 = [License parseJsonArray:jsonArray];
                NSLog(@"parsed licenses: %ld", (long)licenses1.count);
                [conn.finalDelegate performSelector:@selector(licenses:) withObject:licenses1];
            }else
                NSLog(@"cannot send licenses to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeOther]){// history, code, attributes
            // parse and return
        
        }else if([conn.typeTag isEqualToNumber:typeSubmitLicense]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got license");
            if (e != nil) {
                NSLog(@"error deserializing json object, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if([conn.finalDelegate respondsToSelector:@selector(finishedSubmitLicense:)]){
                NSLog(@"responds to selector: finishedSubmitLicense");
                License *license = [[License alloc] initWithDictionary:d];
                [conn.finalDelegate performSelector:@selector(finishedSubmitLicense:) withObject:license];
            }else
                NSLog(@"cant respond to selector finishedSubmitLicense:");
            
        }else if([conn.typeTag isEqualToNumber:typeUserExists] || [conn.typeTag isEqualToNumber:typeSubmitNewUser] || [conn.typeTag isEqualToNumber:typeConfirmUser]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got user");
            if (e != nil) {
                NSLog(@"error deserializing json object, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.typeTag isEqualToNumber:typeConfirmUser]) {
                blockingRequestRunning = false;
                self.user = [[User alloc] initWithDictionary:d];
                NSLog(@"unblocking requests");
                NSLog(@"%@", d);
            }else if([conn.finalDelegate respondsToSelector:@selector(user:)]){
                NSLog(@"responds to selector: user");
                User *user = [[User alloc] initWithDictionary:d];
                [conn.finalDelegate performSelector:@selector(user:) withObject:user];
            }else
                NSLog(@"cant respond to selector user:");
            
        }else if([conn.typeTag isEqualToNumber:typeStates]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got states");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(states:)]) {
                NSLog(@"responds to selector");
                NSArray *states = [State parseJsonArray:jsonArray];
                NSLog(@"parsed states");
                [conn.finalDelegate performSelector:@selector(states:) withObject:states];
            }else
                NSLog(@"cannot send states to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeDealerships]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got dealerships");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(dealerships:)]) {
                NSLog(@"responds to selector");
                NSArray *dealerships = [Dealership parseJsonArray:jsonArray];
                NSLog(@"parsed dealerships");
                [conn.finalDelegate performSelector:@selector(dealerships:) withObject:dealerships];
            }else
                NSLog(@"cannot send dealerships to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeContactInfo] || [conn.typeTag isEqualToNumber:typeSubmitContactInfo]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got contact info");
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(contactInfo:)]) {
                NSLog(@"responds to selector");
                ContactInfo *contactInfo = [[ContactInfo alloc] initWithDictionary:d];
                NSLog(@"parsed contact info");
                [conn.finalDelegate performSelector:@selector(contactInfo:) withObject:contactInfo];
            }else
                NSLog(@"cannot send contactInfo to delegate");
            
        }else if([conn.typeTag isEqualToNumber:typeLicenseImage]){
            NSData *data = [dataFromConnectionByTag objectForKey:conn.uniqueTag];
            NSLog(@"got license image back, lenght: %ld", (unsigned long)data.length);
            if ([conn.finalDelegate respondsToSelector:@selector(imageData:)]) {
                NSLog(@"responds to selector, imageData");
                [conn.finalDelegate performSelector:@selector(imageData:) withObject:data];
            }else
                NSLog(@"cannot send delegate selector: imageData");
        }else if([conn.typeTag isEqualToNumber:typeDeleteLicenseById]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got deletedLicenseWithId");
            if (e != nil) {
                NSLog(@"error deserializing json, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(deletedLicenseWithId:)]) {
                NSLog(@"responds to selector");
                DeleteLicenseResponse *deleteLicenseResponse = [[DeleteLicenseResponse alloc] initWithDictionary:d];
                NSLog(@"parsed deletedLicenseWithId");
                [conn.finalDelegate performSelector:@selector(deletedLicenseWithId:) withObject:deleteLicenseResponse];
            }else
                NSLog(@"cannot send deletedLicenseWithId to delegate");
        }else if([conn.typeTag isEqualToNumber:typeSubmitImageData]){
//            NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got finished info");
            if (e != nil) {
                NSLog(@"error deserializing json, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(finishedPhoto:)]) {
                NSLog(@"responds to selector");
                FinishedPhoto *finishedPhoto = [[FinishedPhoto alloc] initWithDictionary:d];
                NSLog(@"parsed finished photo");
                [conn.finalDelegate performSelector:@selector(finishedPhoto:) withObject:finishedPhoto];
            }else
                NSLog(@"cannot send finishedPhoto to delegate");
        }else if([conn.typeTag isEqualToNumber:typeSubmitLicenseUpdate]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got updatedLicense");
            if (e != nil) {
                NSLog(@"error deserializing json updatedLicense, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(updatedLicense:)]) {
                NSLog(@"responds to selector updatedLicense");
                License *license = [[License alloc] initWithDictionary:d];
                NSLog(@"parsed updatedLicense");
                [conn.finalDelegate performSelector:@selector(updatedLicense:) withObject:license];
            }else
                NSLog(@"cannot send updatedLicense to delegate");
        }else if([conn.typeTag isEqualToNumber:typeStateQuestions]){
            NSLog(@"typeTag: %@", conn.typeTag);
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] options:NSJSONReadingMutableContainers error:&e];
            NSLog(@"got state questions, %@", jsonArray);
            if (e != nil) {
                NSLog(@"error deserializing json array, %@", e.localizedDescription);
                NSLog(@"%@", [[NSString alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag] encoding:NSUTF8StringEncoding]);
                self.parser = [[NSXMLParser alloc] initWithData:[dataFromConnectionByTag objectForKey:conn.uniqueTag]];
                [self.parser setDelegate:self];
                [self.parser parse];
            }else if ([conn.finalDelegate respondsToSelector:@selector(stateQuestions:)]) {
                NSLog(@"responds to selector");
                NSArray *array = [StateQuestions parseJsonArray:jsonArray];
                NSLog(@"parsed stateQuestions: %ld", (long)array.count);
                [conn.finalDelegate performSelector:@selector(stateQuestions:) withObject:array];
            }else
                NSLog(@"cannot send stateQuestions to delegate");
        }else
            NSLog(@"type not accounted for: %@", conn.typeTag);
    }else
        NSLog(@"couldnt find data for typeTag: %@, uniqueTag: %@", conn.typeTag, conn.uniqueTag);
    
    // clean up
    [dataFromConnectionByTag removeObjectForKey:conn.uniqueTag]; // after done using the data, remove it
    [connections removeObjectForKey:conn.uniqueTag];// remove the connection
    [self doFetchQueue];
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
        self.conrollerResponsibleForGoogleLogin = delegate;
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
        if ([self.conrollerResponsibleForGoogleLogin respondsToSelector:@selector(dismissThisViewController:)]) {
            [self.conrollerResponsibleForGoogleLogin performSelector:@selector(dismissThisViewController:) withObject:viewController];
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








































