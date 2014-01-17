//
//  LabelBoolCell.m
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import "LabelBoolCell.h"

int lbcLabelLeftPad = 10;
int lbcLabelTopPad = 10;
int lbcLabelMaxWidth = 200;
int lbcCellBottomPad = 10;

@implementation LabelBoolCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.reuseId = reuseIdentifier;
        
        self.label = [[UILabel alloc] init];
        [self.label setTextColor:[UIColor blackColor]];
        [self.label setBackgroundColor:[UIColor colorWithHue:32 saturation:100 brightness:63 alpha:1]];
        [self.label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        
        self.cellSwitch = [[UISwitch alloc] init];
        [self.cellSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.cellSwitch];
    }
    return self;
}

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    self.qaa = qaa;
    
    CGSize labelSize = CGSizeMake(lbcLabelMaxWidth, 9999);
    CGRect textRect = [self.qaa.question.questionTextEnglish boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    CGRect labelRect = CGRectMake(lbcLabelLeftPad, lbcLabelTopPad, textRect.size.width, textRect.size.height);
    
    [self.label setFrame:labelRect];
    [self.label setText:self.qaa.question.questionTextEnglish];
    
    int leftStuffWidth = lbcLabelLeftPad + labelRect.size.width;
    int remainingWidth = 320 - leftStuffWidth;
    int switchPad = remainingWidth / 2 - self.cellSwitch.frame.size.width / 2;
    int switchY = [LabelBoolCell getCellHeightForQuestionAndAnswer:self.qaa] / 2 - self.cellSwitch.frame.size.height / 2;
    CGRect cellRect = CGRectMake(leftStuffWidth + switchPad, switchY, self.cellSwitch.frame.size.width, self.cellSwitch.frame.size.height);
    [self.cellSwitch setFrame:cellRect];
    [self.cellSwitch setOn:self.qaa.answer.answerBool];
}

+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    CGSize labelSize = CGSizeMake(lbcLabelMaxWidth, 9999);
    CGRect textRect = [qaa.question.questionTextEnglish boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    return lbcLabelTopPad + textRect.size.height + lbcCellBottomPad;
}

+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    return 100;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
