//
//  EditLicenseDetailsViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAOManager.h"
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

- (id)initWithLicense:(License *)license;

@end
