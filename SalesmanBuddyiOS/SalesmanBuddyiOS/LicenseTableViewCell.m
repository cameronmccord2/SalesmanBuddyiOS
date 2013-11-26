//
//  LicenseTableViewCell.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 11/26/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "LicenseTableViewCell.h"

@implementation LicenseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)flagItem:(id)sender{
    
}

-(void)printStuff{
    NSLog(@"print stuff");
}
@end
