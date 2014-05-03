//
//  LicenseImageCell.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"
#import "ImageDetails.h"
#import "QuestionAndAnswer.h"
#import "NewLicenseListViewController.h"

@protocol LicenseImageCellProtocol <NSObject>

-(void)setTabBarSelectedIndex:(NSInteger)index;
-(void)didFinishUploadingImageData;

@end

@interface LicenseImageCell : UITableViewCell <SBDaoV1DelegateProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong)UIImageView *imageV;
//@property(nonatomic, strong)UIImage *image;
@property(nonatomic)NSInteger licenseId;
@property(nonatomic, weak)NSURLConnectionWithExtras *imageConnection;
@property(nonatomic, strong)UIImagePickerController *imagePickerController;
@property(nonatomic, strong)UIAlertView *alert;
@property(nonatomic, weak)NewLicenseListViewController* delegate;
@property(nonatomic, strong)FinishedPhoto *finishedPhoto;
@property(nonatomic)BOOL imageSavingStarted;
@property(nonatomic, strong)QuestionAndAnswer *qaa;

@property(nonatomic, strong)UILabel *requiredLabel;
@property(nonatomic, strong)UILabel *questionLabel;
@property(nonatomic, strong)UIButton *retakeButton;
@property(nonatomic, strong)UIButton *takeButton;
@property(nonatomic, strong)UIProgressView *loadingProgress;
@property(nonatomic)NSInteger cellHeight;


+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa;
+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa;

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa tableDelegate:(NewLicenseListViewController *)tableDelegate;
-(void)closeImageConnections;
-(void)imageThen:(NSURLConnectionWithExtras *)connection progress:(NSProgress *)progress;

@end
