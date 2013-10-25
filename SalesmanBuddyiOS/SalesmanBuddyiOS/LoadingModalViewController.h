//
//  LoadingModalViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingModalViewController : UIViewController

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *message;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
-(void)dismiss;

@end
