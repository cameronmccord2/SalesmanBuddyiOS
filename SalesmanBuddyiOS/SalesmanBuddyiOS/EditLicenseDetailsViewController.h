//
//  EditLicenseDetailsViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"
#import "LoadingModalViewController.h"

@interface EditLicenseDetailsViewController : UIViewController<DAOManagerDelegateProtocal, UITextFieldDelegate>{
    BOOL viewHasLoaded;
    UITextField *activeField;
}

@property(nonatomic, strong)License *license;
@property(nonatomic, strong)NSMutableArray *textFields;
@property(nonatomic, strong)UIImage *licenseImage;
@property(nonatomic, strong)UIAlertView *alert;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic)UIEdgeInsets scrollViewInsets;
@property(nonatomic, strong)LoadingModalViewController *loadingModal;
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, weak)UIViewController *delegate;
@property(nonatomic, strong)NSProgress *progress;
@property(nonatomic, strong)UIProgressView *progressView;
@property(nonatomic, weak)NSURLConnection *imageConnection;

- (id)initWithLicense:(License *)license delegate:(id)delegate;

#pragma mark - DAOManagerDelegateProtocal methods

-(void)connectionObject:(NSURLConnection *)connection;
@end
