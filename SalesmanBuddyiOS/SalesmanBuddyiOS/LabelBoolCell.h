//
//  LabelBoolCell.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelBoolCell : UITableViewCell

@property(nonatomic, strong)NSString *reuseId;
@property(nonatomic, strong)UILabel *label;
@property(nonatomic, strong)UISwitch *cellSwitch;

+(NSInteger)getCellHeightForLabelText:(NSString *)labelText;

-(void)setUpWithLabelText:(NSString *)labelText boolSetTo:(BOOL)boolIs;

@end
