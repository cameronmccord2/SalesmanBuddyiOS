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
-(void)states:(NSArray *)states;
-(void)dealerships:(NSArray *)dealerships;
-(void)questions:(NSArray *)questions;
-(void)answers:(NSArray *)answers;
-(void)questionsAndAnswers:(NSArray *)questionsAndAnswers;
-(void)user:(User *)user;
-(void)finishedPhoto:(FinishedPhoto *)finishedPhoto;
-(void)finishedSubmitLicense:(License *)license;
-(void)deletedLicenseWithId:(DeleteLicenseResponse *)deleteLicenseResponse;
-(void)updatedLicense:(License *)updatedLicense;
-(void)imageData:(NSData *)data;
-(void)imageThen:(NSURLConnectionWithExtras *)connection progress:(NSProgress *)progress;

@end


@interface SBDaoV1 : DAOManager



@property(nonatomic, strong)User *user;

+(instancetype)sharedManager;
-(void)getQuestionsForDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
-(CLLocationCoordinate2D)getLocation;
-(void)getLicensesForDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)getStates:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)getDealerships:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)getUserExists:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)getImageForAnswerId:(NSInteger)answerId forDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)confirmUser;
-(void)putImage:(NSData *)bodyData forStateId:(NSInteger)stateId forDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)putLicense:(License *)license forDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)updateLicense:(License *)license forDelegate:(id<SBDaoV1DelegateProtocol>)delegate;
-(void)deleteLicenseById:(NSInteger)licenseId forDelegate:(id<SBDaoV1DelegateProtocol>)delegate;

@end
