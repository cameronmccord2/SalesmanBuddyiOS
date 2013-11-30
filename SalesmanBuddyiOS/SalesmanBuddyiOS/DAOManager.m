//
//  DAOManager.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/17/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "DAOManager.h"
#import "NSURLConnectionWithExtras.h"
#import "CallQueue.h"
#import "NewUserModalViewController.h"
#import "Dealership.h"
#import "State.h"
#import "StateQuestions.h"
#import "NSURLAdditions.h"
#import "NSStringAdditions.h"

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
        self.kKeychainItemName = @"SalesmanCompanionKeyV02";// set to nil to have the user login every time the app loads
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
        
//        NSLog(@"going to confirm user");
//        [self confirmUser];
    }
    return self;
}

-(NSInteger)getAUniqueTag{
    currentUniqueTag++;
    return currentUniqueTag;
}

-(NSDecimalNumber *)getConnectionNumber{
    [connectionNumber decimalNumberByAdding:[NSDecimalNumber one]];
    return connectionNumber;
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
-(void)makeRequestWithVerb:(NSString *)verb forUrl:(NSURL *)url body:(NSDictionary *)bodyData finalDelegate:(id)delegate success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress{
    NSLog(@"making post request, %@", bodyData);
    NSError *e = nil;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:verb];
    if(bodyData){
        NSData *postData = [NSJSONSerialization dataWithJSONObject:bodyData options:0 error:&e];
        [req setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setHTTPBody:postData];
    }
    if (e != nil) {
        NSLog(@"make post reuqest error: %@", e.localizedDescription);
    }else{
        [callQueue addObject:[CallQueue initWithRequest:req body:bodyData delegate:delegate success:success error:error then:then progress:progress]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

-(void)confirmUser{
    NSLog(@"confirming user");
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, confirmUserUrl]];
    User *user = [[User alloc] init];
    user.deviceType = 1;
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got user");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else{
            blockingRequestRunning = false;
            self.user = [[User alloc] initWithDictionary:d];
            NSLog(@"unblocking requests");
            NSLog(@"%@", d);
//            if([delegate respondsToSelector:@selector(user:)]){
//                NSLog(@"responds to selector: user");
//                User *user = [[User alloc] initWithDictionary:d];
//                [delegate performSelector:@selector(user:) withObject:user];
//            }
        }
        cleanUp();
    };
    
    blockingRequestRunning = YES;
    
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[User dictionaryFromUser:user] finalDelegate:self success:success error:nil then:nil progress:nil];
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
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got finished info");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(finishedPhoto:)]) {
            NSLog(@"responds to selector");
            FinishedPhoto *finishedPhoto = [[FinishedPhoto alloc] initWithDictionary:d];
            NSLog(@"parsed finished photo");
            [delegate performSelector:@selector(finishedPhoto:) withObject:finishedPhoto];
        }else
            NSLog(@"cannot send finishedPhoto to delegate");
        cleanUp();
    };
    
    if(error)
        NSLog(@"%@", error);
    else{
        NSLog(@"putting image");
        [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil progress:nil]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

-(void)putLicense:(License *)license forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    NSLog(@"%@", [License dictionaryFromLicense:license]);
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got license");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if([delegate respondsToSelector:@selector(finishedSubmitLicense:)]){
            NSLog(@"responds to selector: finishedSubmitLicense");
            License *license = [[License alloc] initWithDictionary:d];
            [delegate performSelector:@selector(finishedSubmitLicense:) withObject:license];
        }else
            NSLog(@"cant respond to selector finishedSubmitLicense:");
        cleanUp();
    };
    
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[License dictionaryFromLicense:license] finalDelegate:delegate success:success error:nil then:nil progress:nil];
}

-(void)putContactInfo:(ContactInfo *)contactInfo forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got license");
        if (e != nil) {
           [self doJsonError:data error:e];
        }else if([delegate respondsToSelector:@selector(finishedSubmitLicense:)]){
            NSLog(@"responds to selector: finishedSubmitLicense");
            License *license = [[License alloc] initWithDictionary:d];
            [delegate performSelector:@selector(finishedSubmitLicense:) withObject:license];
        }else
            NSLog(@"cant respond to selector finishedSubmitLicense:");
        cleanUp();
    };
    
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[ContactInfo dictionaryFromContactInfo:contactInfo] finalDelegate:delegate success:success error:nil then:nil progress:nil];
}


#pragma mark - Post Functions

-(void)updateLicense:(License *)license forDelegate:(id)delegate{
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    NSLog(@"%@", [License dictionaryFromLicense:license]);
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got updatedLicense");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(updatedLicense:)]) {
            NSLog(@"responds to selector updatedLicense");
            License *license = [[License alloc] initWithDictionary:d];
            NSLog(@"parsed updatedLicense");
            [delegate performSelector:@selector(updatedLicense:) withObject:license];
        }else
            NSLog(@"cannot send updatedLicense to delegate");
        cleanUp();
    };
    
    [self makeRequestWithVerb:@"POST" forUrl:url body:[License dictionaryFromLicense:license] finalDelegate:delegate success:success error:nil then:nil progress:nil];
}


#pragma mark - Delete Functions

-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id)delegate{
    NSError *error = nil;
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"DELETE"];
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got deletedLicenseWithId");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(deletedLicenseWithId:)]) {
            NSLog(@"responds to selector");
            DeleteLicenseResponse *deleteLicenseResponse = [[DeleteLicenseResponse alloc] initWithDictionary:d];
            NSLog(@"parsed deletedLicenseWithId");
            [delegate performSelector:@selector(deletedLicenseWithId:) withObject:deleteLicenseResponse];
        }else
            NSLog(@"cannot send deletedLicenseWithId to delegate");
        cleanUp();
    };
    
    if(error)
        NSLog(@"%@", error);
    else{
        [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil progress:nil]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}



#pragma mark - Get Functions

-(void)genericGetFunctionForDelegate:(id)delegate forSpecificUrlString:(NSString *)urlPiece success:(void (^)(NSData *, void(^)()))success error:(void (^)(NSData *, NSError *, void(^)()))error then:(void (^)(NSData *))then progress:(void (^)(NSProgress *))progress{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, urlPiece]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
//    [callQueue addObject:[[CallQueue alloc] initQueueItem:req type:type body:nil delegate:delegate]];
    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:error then:then progress:progress]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
//    [self doFetchQueue];
}

-(void)getLicensesForDelegate:(id)delegate{
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"made json array for licenses");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(licenses:)]) {
            NSLog(@"responds to selector licenses");
            NSMutableArray *licenses1 = [License parseJsonArray:jsonArray];
            NSLog(@"parsed licenses: %ld", (long)licenses1.count);
            [delegate performSelector:@selector(licenses:) withObject:licenses1];
        }else
            NSLog(@"cannot send licenses to delegate");
        cleanUp();
    };
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:licensesUrl success:success error:nil then:nil progress:nil];
}

-(void)getStates:(id)delegate{
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got states");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(states:)]) {
            NSLog(@"responds to selector");
            NSArray *states = [State parseJsonArray:jsonArray];
            NSLog(@"parsed states");
            [delegate performSelector:@selector(states:) withObject:states];
        }else
            NSLog(@"cannot send states to delegate");
        cleanUp();
    };
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:statesUrl success:success error:nil then:nil progress:nil];
}

-(void)getDealerships:(id)delegate{
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got dealerships");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(dealerships:)]) {
            NSLog(@"responds to selector");
            NSArray *dealerships = [Dealership parseJsonArray:jsonArray];
            NSLog(@"parsed dealerships");
            [delegate performSelector:@selector(dealerships:) withObject:dealerships];
        }else
            NSLog(@"cannot send dealerships to delegate");
        cleanUp();
    };
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:dealershipsUrl success:success error:nil then:nil progress:nil];
}

-(void)getUserExists:(id)delegate{
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got user");
        if (e != nil) {
           [self doJsonError:data error:e];
        }else if([delegate respondsToSelector:@selector(user:)]){
            NSLog(@"responds to selector: user");
            User *user = [[User alloc] initWithDictionary:d];
            [delegate performSelector:@selector(user:) withObject:user];
        }else
            NSLog(@"cant respond to selector user:");
        cleanUp();
    };
    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:userExistsUrl success:success error:nil then:nil progress:nil];
}

-(void)getContactInfoByContactInfoId:(NSInteger)contactInfoId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    url = [url URLByAppendingQueryStringKey:@"contactinfoid" value:[NSString stringWithFormat:@"%ld", (long)contactInfoId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got contact info");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(contactInfo:)]) {
            NSLog(@"responds to selector");
            ContactInfo *contactInfo = [[ContactInfo alloc] initWithDictionary:d];
            NSLog(@"parsed contact info");
            [delegate performSelector:@selector(contactInfo:) withObject:contactInfo];
        }else
            NSLog(@"cannot send contactInfo to delegate");
        cleanUp();
    };
    
    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil progress:nil]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getContactInfoByLicenseId:(NSInteger)licenseId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got contact info");
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(contactInfo:)]) {
            NSLog(@"responds to selector");
            ContactInfo *contactInfo = [[ContactInfo alloc] initWithDictionary:d];
            NSLog(@"parsed contact info");
            [delegate performSelector:@selector(contactInfo:) withObject:contactInfo];
        }else
            NSLog(@"cannot send contactInfo to delegate");
        cleanUp();
    };
    
    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil progress:nil]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getLicenseImageForLicenseId:(NSInteger)licenseId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, licenseImageUrl]];
    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        if ([delegate respondsToSelector:@selector(imageData:)]) {
            NSLog(@"responds to selector, imageData");
            [delegate performSelector:@selector(imageData:) withObject:data];
        }else
            NSLog(@"cannot send delegate selector: imageData");
        cleanUp();
    };
    
    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil progress:nil]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

-(void)getStateQuestionsForStateId:(NSInteger)stateId forDelegate:(id)delegate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, stateQuestionsUrl]];
    url = [url URLByAppendingQueryStringKey:@"stateid" value:[NSString stringWithFormat:@"%ld", (long)stateId]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"got state questions, %@", jsonArray);
        if (e != nil) {
            [self doJsonError:data error:e];
        }else if ([delegate respondsToSelector:@selector(stateQuestions:)]) {
            NSLog(@"responds to selector");
            NSArray *array = [StateQuestions parseJsonArray:jsonArray];
            NSLog(@"parsed stateQuestions: %ld", (long)array.count);
            [delegate performSelector:@selector(stateQuestions:) withObject:array];
        }else
            NSLog(@"cannot send stateQuestions to delegate");

        cleanUp();
    };
    
    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil progress:nil]];
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
        
        [self.auth authorizeRequest:cq.request completionHandler:^(NSError *error) {
            if (error == nil) {// success
                NSLog(@"auth authorized");
                tryingToAuthenticate = false;
                [cq.request setValue:@"google" forHTTPHeaderField:@"Authprovider"];
//                NSURLConnectionWithTag *connectionObject = [[NSURLConnectionWithTag alloc]initWithRequest:cq.request delegate:self startImmediately:YES typeTag:cq.type uniqueTag:connectionNumber finalDelegate:cq.delegate];
                NSURLConnectionWithExtras *connectionObject = [NSURLConnectionWithExtras connectionWithRequest:cq.request delegate:self startImmediately:YES uniqueTag:[self getConnectionNumber] finalDelegate:cq.delegate success:cq.success error:cq.error then:cq.then progress:cq.progress];
                [connections setObject:connectionObject forKey:connectionNumber];
                
                if ([cq.delegate respondsToSelector:@selector(connectionObject:)]) {// give back connection object so it can be canceled
                    [cq.delegate performSelector:@selector(connectionObject:) withObject:connectionObject];
                }else
                    NSLog(@"doesnt respond to connectionObject:");
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

-(void)doJsonError:(NSData *)data error:(NSError *)error{
    NSLog(@"error deserializing json array, %@", error.localizedDescription);
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSXMLParser *p = [[NSXMLParser alloc] initWithData:data];
    [p setDelegate:self];
    [p parse];
}

#pragma mark - Connection Handling
-(void)connection:(NSURLConnectionWithExtras *)connection didReceiveData:(NSData *)data{
    NSLog(@"saving data for unique tag: %@", connection.uniqueTag);
    if ([dataFromConnectionByTag objectForKey:connection.uniqueTag] == nil) {
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        [dataFromConnectionByTag setObject:newData forKey:connection.uniqueTag];
        connection.nsProgress.completedUnitCount = data.length;
        return;
    }else{
        [[dataFromConnectionByTag objectForKey:connection.uniqueTag] appendData:data];
        
        connection.nsProgress.completedUnitCount += data.length;
        connection.progress(connection.nsProgress);
    }
}

- (void)connection:(NSURLConnectionWithExtras *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{// for upload progress
    connection.nsProgress.totalUnitCount = totalBytesExpectedToWrite;
    connection.nsProgress.completedUnitCount = totalBytesWritten;
    if (connection.progress != nil) {
        connection.progress(connection.nsProgress);
    }
}

- (void) connection:(NSURLConnectionWithExtras *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"did recieve response");
    if([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int status = [httpResponse statusCode];
        if ([connection.typeTag isEqualToNumber:typeUserExists]) {
            if (status == 403) {
                NSLog(@"recieved status unauthorized for typeUserExists");
                [connection cancel];
                if ([connection.finalDelegate respondsToSelector:@selector(showAuthModal:)]) {
                    NewUserModalViewController *rootViewController = [[NewUserModalViewController alloc] initWithNibName:nil bundle:nil];
                    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                    [connection.finalDelegate performSelector:@selector(showAuthModal:) withObject:viewController];
                }else
                    NSLog(@"cant load new user modal");
            }
        }
        
        // NSProgress
        connection.nsProgress.totalUnitCount = response.expectedContentLength;
        if (connection.progress != nil) {
            connection.progress(connection.nsProgress);
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnectionWithExtras *)conn{
    NSLog(@"connection did finish loading");
    
    void (^cleanUp)() = ^void(){
        [dataFromConnectionByTag removeObjectForKey:conn.uniqueTag]; // after done using the data, remove it
        [connections removeObjectForKey:conn.uniqueTag];// remove the connection
        [self doFetchQueue];
    };
    
    NSData *data = [dataFromConnectionByTag objectForKey:conn.uniqueTag];
    
    if (conn.success != nil) {
        conn.success(data, cleanUp);
    }
    if (conn.then != nil) {
        conn.then(data);
    }
    if (conn.progress != nil) {
        conn.nsProgress.completedUnitCount = conn.nsProgress.totalUnitCount;
        conn.progress(conn.nsProgress);
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    self.error = [NSString stringWithFormat:@"%@, %@", self.error, string];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"error: %@", self.error);
    self.error = @"";
}

-(void)connection:(NSURLConnectionWithExtras *)conn didFailWithError:(NSError *)error{
    
    void (^cleanUp)() = ^void(){
        [dataFromConnectionByTag removeObjectForKey:conn.uniqueTag]; // after done using the data, remove it
        [connections removeObjectForKey:conn.uniqueTag];// remove the connection
        [self doFetchQueue];
    };
    
    if (conn.error != nil) {
        conn.error([dataFromConnectionByTag objectForKey:conn.uniqueTag], error, cleanUp);
    }
    
    
    
    
    
    
    
    
    // DO A GLOBAL ERROR HANDLER FOR NOW FOR MY DAO
    
    NSString *errorString = [NSString stringWithFormat:@"Fetch  failed for url: %@, error: %@", conn.originalRequest.URL.absoluteString, [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
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
        NSLog(@"auth can authorize");
        self.auth = auth;
        [self doFetchQueue];
    }
}

-(void)signOutOfGoogle{
    NSLog(@"signing out");
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
}


@end








































