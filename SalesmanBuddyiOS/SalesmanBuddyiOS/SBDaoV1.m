//
//  SBDaoV1.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 12/5/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "SBDaoV1.h"
#import "NewUserModalViewController.h"
//#import "Dealership.h"
//#import "State.h"
#import "QuestionAndAnswer.h"
#import "User.h"
#import "License.h"

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

@implementation SBDaoV1

+(SBDaoV1 *)sharedManager{
    static SBDaoV1 *sharedManager;
    @synchronized(self){// this is if multiple threads do this at the exact same time
        if (!sharedManager) {
            sharedManager = [[SBDaoV1 alloc] init];
        }
        return sharedManager;
    }
}

-(instancetype)init{
    self = [super init];
    if (self != nil) {
        self.kKeychainItemName = @"SalesmanCompanionKeyV02";// set to nil to have the user login every time the app loads
        self.kMyClientID = @"38235450166-dgbh1m7aaab7kopia2upsdj314odp8fc.apps.googleusercontent.com";     // pre-assigned by service
        self.kMyClientSecret = @"zC738ZbMHopT2C1cyKiKDBQ6"; // pre-assigned by service
        [self addAuthScope:@"https://www.googleapis.com/auth/plus.me"];// scope for Google+ API
        
        NSLog(@"going to get the current location");
        [self getLocation];
    }
    return self;
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

-(void)getQuestionsForDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, @"questions"] selector:@selector(questions:) parseClass:[Question class]];
}

-(void)getLicensesForDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl] selector:@selector(licenses:) parseClass:[License class]];
//    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl];
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"made json array for licenses");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if ([delegate respondsToSelector:@selector(licenses:)]) {
//            NSLog(@"responds to selector licenses");
//            NSMutableArray *licenses1 = [License parseJsonArray:jsonArray];
//            NSLog(@"parsed licenses: %ld", (long)licenses1.count);
//            [delegate performSelector:@selector(licenses:) withObject:licenses1];
//        }else
//            NSLog(@"cannot send licenses to delegate");
//        cleanUp();
//    };
//    [self genericGetFunctionForDelegate:delegate forUrlString:url success:success error:nil then:nil];
}

//-(void)getStates:(id)delegate{
//    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, statesUrl];
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got states");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if ([delegate respondsToSelector:@selector(states:)]) {
//            NSLog(@"responds to selector");
//            NSArray *states = [State parseJsonArray:jsonArray];
//            NSLog(@"parsed states");
//            [delegate performSelector:@selector(states:) withObject:states];
//        }else
//            NSLog(@"cannot send states to delegate");
//        cleanUp();
//    };
////    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:statesUrl success:success error:nil then:nil];
//    [self genericGetFunctionForDelegate:delegate forUrlString:url success:success error:nil then:nil];
//}

//-(void)getDealerships:(id)delegate{
//    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, dealershipsUrl];
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got dealerships");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if ([delegate respondsToSelector:@selector(dealerships:)]) {
//            NSLog(@"responds to selector");
//            NSArray *dealerships = [Dealership parseJsonArray:jsonArray];
//            NSLog(@"parsed dealerships");
//            [delegate performSelector:@selector(dealerships:) withObject:dealerships];
//        }else
//            NSLog(@"cannot send dealerships to delegate");
//        cleanUp();
//    };
////    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:dealershipsUrl success:success error:nil then:nil];
//    [self genericGetFunctionForDelegate:delegate forUrlString:url success:success error:nil then:nil];
//}

-(void)getUserExists:(id<SBDaoV1DelegateProtocol>)delegate{
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, userExistsUrl] selector:@selector(user:) parseClass:[User class]];
//    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, userExistsUrl];
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got user");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if([delegate respondsToSelector:@selector(user:)]){
//            NSLog(@"responds to selector: user");
//            User *user = [[User alloc] initWithDictionary:d];
//            [delegate performSelector:@selector(user:) withObject:user];
//        }else
//            NSLog(@"cant respond to selector user:");
//        cleanUp();
//    };
////    [self genericGetFunctionForDelegate:delegate forSpecificUrlString:userExistsUrl success:success error:nil then:nil];
//    [self genericGetFunctionForDelegate:delegate forUrlString:url success:success error:nil then:nil];
}

//-(void)getContactInfoByContactInfoId:(NSInteger)contactInfoId forDelegate:(id)delegate{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
//    url = [url URLByAppendingQueryStringKey:@"contactinfoid" value:[NSString stringWithFormat:@"%ld", (long)contactInfoId]];
//    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
//    
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got contact info");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if ([delegate respondsToSelector:@selector(contactInfo:)]) {
//            NSLog(@"responds to selector");
//            ContactInfo *contactInfo = [[ContactInfo alloc] initWithDictionary:d];
//            NSLog(@"parsed contact info");
//            [delegate performSelector:@selector(contactInfo:) withObject:contactInfo];
//        }else
//            NSLog(@"cannot send contactInfo to delegate");
//        cleanUp();
//    };
//    
//    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil]];
//    [self makeAuthViableAndExecuteCallQueue:delegate];
//}
//
//-(void)getContactInfoByLicenseId:(NSInteger)licenseId forDelegate:(id)delegate{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
//    url = [url URLByAppendingQueryStringKey:@"licenseid" value:[NSString stringWithFormat:@"%ld", (long)licenseId]];
//    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
//    
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got contact info");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if ([delegate respondsToSelector:@selector(contactInfo:)]) {
//            NSLog(@"responds to selector");
//            ContactInfo *contactInfo = [[ContactInfo alloc] initWithDictionary:d];
//            NSLog(@"parsed contact info");
//            [delegate performSelector:@selector(contactInfo:) withObject:contactInfo];
//        }else
//            NSLog(@"cannot send contactInfo to delegate");
//        cleanUp();
//    };
//    
//    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil]];
//    [self makeAuthViableAndExecuteCallQueue:delegate];
//}

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
    
    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil]];
    [self makeAuthViableAndExecuteCallQueue:delegate];
}

//-(void)getStateQuestionsForStateId:(NSInteger)stateId forDelegate:(id)delegate{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, stateQuestionsUrl]];
//    url = [url URLByAppendingQueryStringKey:@"stateid" value:[NSString stringWithFormat:@"%ld", (long)stateId]];
//    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
//    
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got state questions, %@", jsonArray);
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if ([delegate respondsToSelector:@selector(stateQuestions:)]) {
//            NSLog(@"responds to selector");
//            NSArray *array = [StateQuestions parseJsonArray:jsonArray];
//            NSLog(@"parsed stateQuestions: %ld", (long)array.count);
//            [delegate performSelector:@selector(stateQuestions:) withObject:array];
//        }else
//            NSLog(@"cannot send stateQuestions to delegate");
//        
//        cleanUp();
//    };
//    
//    [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil]];
//    [self makeAuthViableAndExecuteCallQueue:delegate];
//}

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
    
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[User dictionaryFromUser:user] finalDelegate:self success:success error:nil then:nil];
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
        [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil]];
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
    
    [self makeRequestWithVerb:@"PUT" forUrl:url body:[License dictionaryFromLicense:license] finalDelegate:delegate success:success error:nil then:nil];
}

//-(void)putContactInfo:(ContactInfo *)contactInfo forDelegate:(id)delegate{
//    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, contactInfoUrl]];
//    
//    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//        NSError *e = nil;
//        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//        NSLog(@"got license");
//        if (e != nil) {
//            [self doJsonError:data error:e];
//        }else if([delegate respondsToSelector:@selector(finishedSubmitLicense:)]){
//            NSLog(@"responds to selector: finishedSubmitLicense");
//            License *license = [[License alloc] initWithDictionary:d];
//            [delegate performSelector:@selector(finishedSubmitLicense:) withObject:license];
//        }else
//            NSLog(@"cant respond to selector finishedSubmitLicense:");
//        cleanUp();
//    };
//    
//    [self makeRequestWithVerb:@"PUT" forUrl:url body:[ContactInfo dictionaryFromContactInfo:contactInfo] finalDelegate:delegate success:success error:nil then:nil];
//}


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
    
    [self makeRequestWithVerb:@"POST" forUrl:url body:[License dictionaryFromLicense:license] finalDelegate:delegate success:success error:nil then:nil];
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
        [callQueue addObject:[CallQueue initWithRequest:req body:nil delegate:delegate success:success error:nil then:nil]];
        [self makeAuthViableAndExecuteCallQueue:delegate];
    }
}

@end
































