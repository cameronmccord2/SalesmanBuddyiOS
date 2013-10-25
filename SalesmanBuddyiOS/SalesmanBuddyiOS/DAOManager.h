//
//  DAOManager.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/17/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "ContactInfo.h"
#import "User.h"
#import "License.h"
#import "FinishedPhoto.h"
#import "DeleteLicenseResponse.h"

@interface DAOManager : NSObject<CLLocationManagerDelegate, NSXMLParserDelegate>{
    NSMutableArray *licenses;
    NSMutableArray *callQueue;
    NSDecimalNumber *connectionNumber;
    NSNumber *typeLicenses;
    NSNumber *typeOther;
    NSNumber *typeUserExists;
    NSNumber *typeDealerships;
    NSNumber *typeContactInfo;
    NSNumber *typeLicenseImage;
    NSNumber *typeStateQuestions;
    NSNumber *typeStates;
    NSNumber *typeSubmitNewUser;
    NSNumber *typeSubmitLicense;
    NSNumber *typeSubmitContactInfo;
    NSNumber *typeSubmitImageData;
    NSNumber *typeConfirmUser;
    NSNumber *typeDeleteLicenseById;
    NSNumber *typeSubmitLicenseUpdate;
    NSMutableDictionary *dataFromConnectionByTag;
    NSMutableDictionary *connections;
    BOOL tryingToAuthenticate;
    BOOL blockingRequestRunning;
    NSInteger currentUniqueTag;
}

@property(nonatomic, strong)GTMOAuth2Authentication* auth;
@property(nonatomic, strong)NSString *kKeychainItemName;
@property(nonatomic, strong)NSString *kMyClientID;
@property(nonatomic, strong)NSString *kMyClientSecret;
@property(nonatomic, strong)NSString *scope;
@property(nonatomic, strong)User *user;
@property(nonatomic, strong)NSString *error;
@property(nonatomic, strong)NSXMLParser *parser;

+(DAOManager *)sharedManager;
-(void)signOutOfGoogle;
-(void)confirmUser;
-(User *)getUser;
-(CLLocationCoordinate2D)getLocation;
-(void)putImage:(NSData *)bodyData forStateId:(NSInteger)stateId forDelegate:(id)delegate;
-(void)putLicense:(License *)license forDelegate:(id)delegate;
-(void)putContactInfo:(ContactInfo *)contactInfo forDelegate:(id)delegate;
-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id)delegate;
-(void)genericGetFunctionForDelegate:(id)delegate forSpecificUrlString:(NSString *)urlPiece forType:(NSNumber *)type;
-(void)getLicensesForDelegate:(id)delegate;
-(void)getStates:(id)delegate;
-(void)getDealerships:(id)delegate;
-(void)getUserExists:(id)delegate;
-(void)getContactInfoByContactInfoId:(NSInteger)contactInfoId forDelegate:(id)delegate;
-(void)getContactInfoByLicenseId:(NSInteger)licenseId forDelegate:(id)delegate;
-(void)getLicenseImageForLicenseId:(NSInteger)licenseId forDelegate:(id)delegate;
-(void)getStateQuestionsForStateId:(NSInteger)stateId forDelegate:(id)delegate;

-(NSInteger)getAUniqueTag;


// google callbacks
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;

@end

@protocol DAOManagerDelegateProtocal <NSObject>

-(void)showThisModal:(UIViewController *)viewController;

@optional
-(void)licenses:(NSArray *)licenses;
-(void)stateQuestions:(NSArray *)stateQuestions;
-(void)contactInfo:(ContactInfo *)contactInfo;
-(void)dealerships:(NSArray *)dealerships;
-(void)states:(NSArray *)states;
-(void)user:(User *)user;
-(void)licenseImage:(NSData *)imageData;
-(void)finishedPhoto:(FinishedPhoto *)finishedPhoto;
-(void)finishedSubmitLicense:(License *)license;
-(void)deletedLicenseWithId:(DeleteLicenseResponse *)deleteLicenseResponse;
-(void)updatedLicense:(License *)updatedLicense;
-(void)imageData:(NSData *)data;

@end