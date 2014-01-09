//
//  NewLicenseViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"
#import "LoadingModalViewController.h"


@interface NewLicenseViewController : UIViewController<DAOManagerDelegateProtocal, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>{
    BOOL viewHasLoaded;
    UITextField *activeField;
    BOOL licenseImageSavingStarted;
    BOOL licenseIsReady;
}

@property(nonatomic, strong)NSManagedObjectContext *context;
@property(nonatomic, strong)NSArray *stateQuestions;
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImagePickerController *imagePickerController;
@property(nonatomic, strong)UIAlertView *alert;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)NSMutableArray *textFields;
@property(nonatomic, strong)UIImage *licenseImage;
@property(nonatomic, strong)ContactInfo *contactInfo;
@property(nonatomic, strong)FinishedPhoto *finishedPhoto;
@property(nonatomic, strong)License *license;
@property(nonatomic)UIEdgeInsets scrollViewInsets;
@property(nonatomic, strong)LoadingModalViewController *loadingModal;


- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
