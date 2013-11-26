//
//  LicenseTableViewCell.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/26/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicenseTableViewCell : UITableViewCell

@property(nonatomic, strong)IBOutlet UILabel *name;
@property(nonatomic, strong)IBOutlet UILabel *details;
@property(nonatomic, strong)IBOutlet UIImageView *flag;

-(IBAction)flagItem:(id)sender;
-(void)printStuff;
@end
