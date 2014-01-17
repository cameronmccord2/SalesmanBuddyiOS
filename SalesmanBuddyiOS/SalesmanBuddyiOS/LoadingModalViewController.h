//
//  LoadingModalViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAOManager.h"
@interface LoadingModalViewController : UIViewController<DAOManagerDelegateProtocol>

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *message;
@property(nonatomic, strong)NSProgress *progress;
@property(nonatomic, strong)UILabel *lastLabel;
@property(nonatomic)BOOL useUploadProgress;

- (id)initWithTitle:(NSString *)title message:(NSString *)message useUploadProgress:(BOOL)useUploadProgress;
-(void)dismiss;
-(void)connectionUploadProgress:(NSNumber *)progress total:(NSNumber *)total;

@end
