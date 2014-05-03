//
//  SubmitCancelCell.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/9/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import "SubmitCancelCell.h"

@implementation SubmitCancelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.submitButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 10, 100, 50)];
        [self.submitButton setBackgroundColor:[UIColor greenColor]];
        [self.submitButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [self.submitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 10, 100, 50)];// 40+100+30
        [self.cancelButton setBackgroundColor:[UIColor redColor]];
        [self.cancelButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    return 70;
}

+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    return [SubmitCancelCell getCellHeightForQuestionAndAnswer:qaa];
}

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa tableDelegate:(id<SubmitCancelProtocol>)tableDelegate{
    self.delegate = tableDelegate;
    [self.contentView addSubview:self.submitButton];
    [self.contentView addSubview:self.cancelButton];
}

-(void)submit:(id)sender{
//    NSLog(@"submitting");
    [self.delegate submit];
    
}

-(void)cancel:(id)sender{
//    NSLog(@"cancelling");
    [self.delegate cancel];
}

@end
