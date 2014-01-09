//
//  LicenseImageCell.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import "LicenseImageCell.h"
#import "SBDaoV1.h"


@implementation LicenseImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 400, 200)];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithLicenseId:(NSInteger)licenseId{
    self.licenseId = licenseId;
    [[SBDaoV1 sharedManager] getLicenseImageForLicenseId:licenseId forDelegate:self];
}

-(void)imageData:(NSData *)data{
#warning finish this
}

-(UIButton *)makeTakeImageButton{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 200, 100)];
    [button setBackgroundColor:[UIColor greenColor]];
    [button setTitle:@"Take Image" forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:controlEvent];
    return button;
}

#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
//    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
//    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
