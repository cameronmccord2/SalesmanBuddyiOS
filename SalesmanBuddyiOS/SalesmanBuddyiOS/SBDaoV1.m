// Do users exists call
//
//
//  SBDaoV1.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 12/5/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "SBDaoV1.h"
#import "NewUserModalViewController.h"
#import "Dealership.h"
#import "State.h"
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

enum{
    Junk = 0, ConfirmUserType = 1, StoreType = 5, NormalType = 9
};

-(instancetype)init{
    self = [super init];
    if (self != nil) {
        self.kKeychainItemName = @"SalesmanCompanionKeyV02";// set to nil to have the user login every time the app loads
        self.kMyClientID = @"38235450166-dgbh1m7aaab7kopia2upsdj314odp8fc.apps.googleusercontent.com";     // pre-assigned by service
        self.kMyClientSecret = @"zC738ZbMHopT2C1cyKiKDBQ6"; // pre-assigned by service
        [self addAuthScope:@"https://www.googleapis.com/auth/plus.me"];// scope for Google+ API
//        
//        
//        
//        void(^confirmUserFunction)(id<DAOManagerDelegateProtocol>) = ^void(id<DAOManagerDelegateProtocol> authDelegate){
//            User *user = [[User alloc] init];
//            user.deviceType = 1;
//            
//            blockingRequestRunning = YES;
//            
//            void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
//                NSError *e = nil;
//                NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
//                NSLog(@"got user");
//                if (e != nil) {
//                    [self doJsonError:data error:e];
//                }else{
//                    blockingRequestRunning = NO;
//                    self.userConfirmed = YES;
//                    self.user = [[User alloc] initWithDictionary:d];
//                    NSLog(@"unblocking requests");
//                    NSLog(@"%@", d);
//                    //            if([delegate respondsToSelector:@selector(user:)]){
//                    //                NSLog(@"responds to selector: user");
//                    //                User *user = [[User alloc] initWithDictionary:d];
//                    //                [delegate performSelector:@selector(user:) withObject:user];
//                    //            }
//                }
//                cleanUp();
//            };
//            
//            [self makeRequestWithVerb:@"PUT" forUrl:[NSString stringWithFormat:@"%@%@", baseUrl, confirmUserUrl] bodyDictionary:[User dictionaryFromUser:user] bodyData:nil authDelegate:authDelegate contentType:@"application/json" requestType:ConfirmUserType success:success error:nil then:nil];
//        };
//        
//        self.confirmUserFunction = confirmUserFunction;
//        
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
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, @"questions"] selector:@selector(questions:) parseClass:[Question class] requestType:NormalType];
}

-(void)getLicensesForDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    NSLog(@"getting licenses");
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl] selector:@selector(licenses:) parseClass:[License class] requestType:NormalType];
}

-(void)getStates:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, statesUrl] selector:@selector(states:) parseClass:[State class] requestType:NormalType];
}

-(void)getDealerships:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    [self genericListGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, dealershipsUrl] selector:@selector(dealerships:) parseClass:[Dealership class] requestType:NormalType];
}

//-(void)getUserExists:(id<SBDaoV1DelegateProtocol>)delegate{
//    [self confirmUserWithAuthDelegateIfNeeded:delegate];
//    [self genericObjectGetForDelegate:delegate url:[NSString stringWithFormat:@"%@%@", baseUrl, userExistsUrl] selector:@selector(user:) parseClass:[User class] requestType:NormalType];
//}

-(void)getImageForAnswerId:(NSInteger)answerId forDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    NSLog(@"getting image");
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    void(^success)(NSData *, void(^)()) = ^void(NSData *data, void(^cleanUp)()){
        if ([delegate respondsToSelector:@selector(imageData:)]) {
            NSLog(@"responds to selector, imageData");
            [delegate performSelector:@selector(imageData:) withObject:data];
        }else
            NSLog(@"cannot send delegate selector: imageData");
        cleanUp();
    };
    
    [self genericGetFunctionForDelegate:delegate forUrlString:[NSString stringWithFormat:@"%@%@?answerid=%ld", baseUrl, licenseImageUrl, (long)answerId] requestType:NormalType success:success error:[self errorTemplateForDelegate:delegate selectorOnError:nil] then:[self thenTemplateForDelegate:self selectorOnThen:@selector(imageThen:progress:)]];
}

-(void)putImage:(NSData *)bodyData forStateId:(NSInteger)stateId forDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl, saveImageUrl];
    url = [url URLStringByAppendingQueryStringKey:@"stateid" value:[NSString stringWithFormat:@"%ld", (long)stateId]];
    url = [url URLStringByAppendingQueryStringKey:@"base64" value:[NSString stringWithFormat:@"1"]];
    
    [self makeRequestWithVerb:@"PUT" forUrl:url bodyDictionary:nil bodyData:bodyData authDelegate:delegate contentType:@"image/jpeg" requestType:NormalType success:[self successTemplateForDelegate:delegate selectorOnSuccess:@selector(imageFinished:) parseClass:[FinishedPhoto class] resultIsArray:NO] error:nil then:[self thenTemplateForDelegate:delegate selectorOnThen:@selector(imageThen:progress:)]];
}

-(void)putLicense:(License *)license forDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    NSLog(@"posting license: %@", [License dictionaryFromLicense:license]);
    [self makeRequestWithVerb:@"PUT" forUrl:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl] bodyDictionary:[License dictionaryFromLicense:license] bodyData:nil authDelegate:delegate contentType:@"application/json" requestType:NormalType success:[self successTemplateForDelegate:delegate selectorOnSuccess:@selector(finishedSubmitLicense:) parseClass:[License class] resultIsArray:NO] error:nil then:nil];
}


#pragma mark - Post Functions

-(void)updateLicense:(License *)license forDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    [self makeRequestWithVerb:@"POST" forUrl:[NSString stringWithFormat:@"%@%@", baseUrl, licensesUrl] bodyDictionary:[License dictionaryFromLicense:license] bodyData:nil authDelegate:delegate contentType:@"application/json" requestType:NormalType success:[self successTemplateForDelegate:delegate selectorOnSuccess:@selector(updatedLicense:) parseClass:[License class] resultIsArray:NO] error:nil then:nil];
}


#pragma mark - Delete Functions

-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id<SBDaoV1DelegateProtocol>)delegate{
    [self confirmUserWithAuthDelegateIfNeeded:delegate];
    [self makeRequestWithVerb:@"DELETE" forUrl:[NSString stringWithFormat:@"%@%@?licenseid=%ld", baseUrl, licensesUrl, (long)licenseId] bodyDictionary:nil bodyData:nil authDelegate:delegate contentType:nil requestType:NormalType success:[self successTemplateForDelegate:delegate selectorOnSuccess:@selector(deletedLicenseWithId:) parseClass:[DeleteLicenseResponse class] resultIsArray:NO] error:nil then:nil];
}

-(void)confirmUserWithAuthDelegateIfNeeded:(id<DAOManagerDelegateProtocol>)authDelegate{
    if (!self.userConfirmed) {
        User *user = [[User alloc] init];
        user.deviceType = 1;
        
        [self makeRequestWithVerb:@"PUT" forUrl:[NSString stringWithFormat:@"%@%@", baseUrl, confirmUserUrl] bodyDictionary:[User dictionaryFromUser:user] bodyData:nil authDelegate:authDelegate contentType:@"application/json" requestType:ConfirmUserType success:[self successTemplateForDelegate:self selectorOnSuccess:@selector(gotUser:) parseClass:[User class] resultIsArray:NO] error:nil then:nil];
    }
}

-(void)gotUser:(User *)user{
    NSLog(@"confirmed user, %@", [User dictionaryFromUser:user]);
    blockingRequestRunning = NO;
    self.userConfirmed = YES;
}

@end
































