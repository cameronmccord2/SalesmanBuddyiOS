//
//  LabelTextFieldCell.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelTextFieldCell : UITableViewCell

@property(nonatomic, strong)NSString *reuseId;
@property(nonatomic, strong)UILabel *label;
@property(nonatomic, strong)UITextField *textField;
@property(nonatomic, strong)UILabel *requiredLabel;

+(NSInteger)getCellHeightForLabelText:(NSString *)labelText;

-(void)setUpWithLabelText:(NSString *)labelText textFieldText:(NSString *)textFieldText;

@end
