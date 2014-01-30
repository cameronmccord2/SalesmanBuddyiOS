//
//  NewLicenseListViewController.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"

@protocol SubmitCancelProtocol;
@protocol LicenseImageCellProtocol;

@interface NewLicenseListViewController : UITableViewController <SBDaoV1DelegateProtocol, SubmitCancelProtocol, LicenseImageCellProtocol>

@property(nonatomic, strong)NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong)License *license;
@property(nonatomic, strong)id<SBDaoV1DelegateProtocol> delegate;
@property(nonatomic, weak)NSURLConnectionWithExtras *imageConnection;
@property(nonatomic)BOOL isTabInstance;
@property(nonatomic, strong)UIAlertView *alert;

- (instancetype)initWithContext:(NSManagedObjectContext *)managedObjectContext license:(License *)license delegate:(id)delegate;

-(void)questions:(NSArray *)questions;

-(void)dismissAuthModal:(UIViewController *)viewController;
-(void)showAuthModal:(UIViewController *)viewController;

-(void)setTabBarSelectedIndex:(NSInteger)index;

@end
