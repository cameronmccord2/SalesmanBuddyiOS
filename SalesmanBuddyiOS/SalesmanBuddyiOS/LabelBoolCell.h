//
//  LabelBoolCell.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionAndAnswer.h"

@interface LabelBoolCell : UITableViewCell

@property(nonatomic, strong)NSString *reuseId;
@property(nonatomic, strong)UILabel *label;
@property(nonatomic, strong)UISwitch *cellSwitch;
@property(nonatomic, strong)QuestionAndAnswer *qaa;

+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa;
+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa;

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa;

@end
