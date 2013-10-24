//
//  NewLicenseViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAOManager.h"

@interface NewLicenseViewController : UIViewController<DAOManagerDelegateProtocal, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>{
    BOOL viewHasLoaded;
    UITextField *activeField;
}

@property(nonatomic, strong)NSManagedObjectContext *context;
@property(nonatomic, strong)NSArray *stateQuestions;
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImagePickerController *imagePickerController;
@property(nonatomic, strong)UIAlertView *alert;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)NSMutableArray *textFields;
@property(nonatomic, strong)UIImage *licenseImage;


- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
