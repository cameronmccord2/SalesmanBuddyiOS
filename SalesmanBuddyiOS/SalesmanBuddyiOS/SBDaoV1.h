//
//  SBDaoV1.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 12/5/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "DAOManager.h"
#import "User.h"
#import "FinishedPhoto.h"
#import "License.h"
#import "DeleteLicenseResponse.h"

@protocol SBDaoV1DelegateProtocol <DAOManagerDelegateProtocol>

@optional

-(void)licenses:(NSArray *)licenses;
-(void)questions:(NSArray *)questions;
-(void)answers:(NSArray *)answers;
-(void)questionsAndAnswers:(NSArray *)questionsAndAnswers;
-(void)user:(User *)user;
-(void)licenseImage:(NSData *)imageData;
-(void)finishedPhoto:(FinishedPhoto *)finishedPhoto;
-(void)finishedSubmitLicense:(License *)license;
-(void)deletedLicenseWithId:(DeleteLicenseResponse *)deleteLicenseResponse;
-(void)updatedLicense:(License *)updatedLicense;
-(void)imageData:(NSData *)data;

@end


@interface SBDaoV1 : DAOManager



@property(nonatomic, strong)User *user;

+(instancetype)sharedManager;
-(void)getQuestionsForDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
//-(instancetype)init;
-(CLLocationCoordinate2D)getLocation;
-(void)getLicensesForDelegate:(id)delegate;
-(void)getStates:(id)delegate;
-(void)getDealerships:(id)delegate;
-(void)getUserExists:(id)delegate;
-(void)getContactInfoByContactInfoId:(NSInteger)contactInfoId forDelegate:(id)delegate;
-(void)getContactInfoByLicenseId:(NSInteger)licenseId forDelegate:(id)delegate;
-(void)getLicenseImageForLicenseId:(NSInteger)licenseId forDelegate:(id)delegate;
-(void)getStateQuestionsForStateId:(NSInteger)stateId forDelegate:(id)delegate;
-(void)confirmUser;
-(void)putImage:(NSData *)bodyData forStateId:(NSInteger)stateId forDelegate:(id)delegate;
-(void)putLicense:(License *)license forDelegate:(id)delegate;
//-(void)putContactInfo:(ContactInfo *)contactInfo forDelegate:(id)delegate;
-(void)updateLicense:(License *)license forDelegate:(id)delegate;
-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id)delegate;

@end
