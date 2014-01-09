//
//  NewLicenseListViewController.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"

@interface NewLicenseListViewController : UITableViewController <SBDaoV1DelegateProtocol>

//@property(nonatomic, strong)NSMutableArray *qaas;
@property(nonatomic, strong)License *license;

-(instancetype)initWithLicense:(License *)license;
-(void)questions:(NSArray *)questions;

-(void)dismissAuthModal:(UIViewController *)viewController;
-(void)showAuthModal:(UIViewController *)viewController;
@end
