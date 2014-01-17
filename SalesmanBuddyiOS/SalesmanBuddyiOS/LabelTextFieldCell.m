//
//  LabelTextFieldCell.m
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import "LabelTextFieldCell.h"

int ltfcLabelLeftPad = 10;
int ltfcLabelTopPad = 10;
int ltfcLabelMaxWidth = 240;
int ltfcTextFieldTopPad = 10;
int ltfcTextFieldLeftPad = 15;
int ltfcTextFieldMaxWidth = 260;
int ltfcTextFieldHeight = 30;
int ltfcBottomPad = 10;
int ltfcRequiredLabelWidth = 300;
int ltfcRequiredLabelLeftPad = 10;
int ltfcRequiredLabelTopPad = 0;
NSString *ltfcRequiredLabelText = @"Required";

@implementation LabelTextFieldCell

@synthesize label;
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.reuseId = reuseIdentifier;
        
        self.label = [[UILabel alloc] init];
        [self.label setTextColor:[UIColor blackColor]];
//        [self.label setBackgroundColor:[UIColor colorWithHue:32 saturation:100 brightness:63 alpha:1]];
        [self.label setFont:[UIFont systemFontOfSize:15.0f]];
        [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        
        self.textField = [[UITextField alloc] init];
        [self.textField setFont:[UIFont systemFontOfSize:15.0f]];
//        [self.textField setBackgroundColor:[UIColor purpleColor]];
        [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.textField];
        
        self.requiredLabel = [[UILabel alloc] init];
        [self.requiredLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.requiredLabel setText:ltfcRequiredLabelText];
        [self.requiredLabel setTextAlignment:NSTextAlignmentRight];
        [self.requiredLabel setTextColor:[UIColor blueColor]];
        [self.requiredLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.requiredLabel];
    }
    return self;
}

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    self.qaa = qaa;
    // make text label
    CGSize labelSize = CGSizeMake(ltfcLabelMaxWidth, 9999);
    CGRect textRect = [self.qaa.question.questionTextEnglish boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    CGRect labelRect = CGRectMake(ltfcLabelLeftPad, ltfcLabelTopPad, textRect.size.width, textRect.size.height);
    NSLog(@"The text is: %@", self.qaa.question.questionTextEnglish);
    NSLog(@"text: %@, width: %ld", self.qaa.question.questionTextEnglish, (long)textRect.size.width);
    
    // make required label rect
    CGSize requiredSize = CGSizeMake(ltfcRequiredLabelWidth, 9999);
    CGRect requiredRect = [ltfcRequiredLabelText boundingRectWithSize:requiredSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]} context:nil];
    CGRect requiredLabelRect = CGRectMake(ltfcRequiredLabelLeftPad, ltfcRequiredLabelTopPad, ltfcRequiredLabelWidth, requiredRect.size.height);
    
    // make text field rect
    CGRect textFieldRect = CGRectMake(ltfcTextFieldLeftPad, ltfcLabelTopPad + labelRect.size.height + ltfcTextFieldTopPad, ltfcTextFieldMaxWidth, ltfcTextFieldHeight);
    
    // set up labels
    [self.label setFrame:labelRect];
    [self.label setText:self.qaa.question.questionTextEnglish];
    [self.requiredLabel setFrame:requiredLabelRect];
    [self.requiredLabel setText:ltfcRequiredLabelText];
    [self.textField setFrame:textFieldRect];
    [self.textField setText:self.qaa.answer.answerText];
    self.textField.layer.borderWidth = 0.5f;
    self.textField.layer.borderColor = [[UIColor grayColor] CGColor];
}

+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    CGSize labelSize = CGSizeMake(ltfcLabelMaxWidth, 9999);
    CGRect textRect = [qaa.question.questionTextEnglish boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    NSLog(@"%ld", (long)(ltfcLabelTopPad + textRect.size.height + ltfcTextFieldTopPad + ltfcTextFieldHeight + ltfcBottomPad));
    return ltfcLabelTopPad + textRect.size.height + ltfcTextFieldTopPad + ltfcTextFieldHeight + ltfcBottomPad;
}

+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    return 100;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
//    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
