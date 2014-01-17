//
//  SettingsViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/25/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"

@interface SettingsViewController : UIViewController<SBDaoV1DelegateProtocol, UITextFieldDelegate>{
    UITextField *activeField;
}

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic)UIEdgeInsets scrollViewInsets;
@property(nonatomic, strong)NSString *feedback;

@end
