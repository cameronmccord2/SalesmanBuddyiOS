//
//  LicenseImageCell.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"

@interface LicenseImageCell : UITableViewCell <SBDaoV1DelegateProtocol>

@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UIImage *image;
@property(nonatomic)NSInteger licenseId;

@end
