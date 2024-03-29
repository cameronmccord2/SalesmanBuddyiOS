//
//  SubmitCancelCell.h
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/9/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionAndAnswer.h"

@protocol SubmitCancelProtocol <NSObject>

-(void)submit;
-(void)cancel;

@end

@interface SubmitCancelCell : UITableViewCell

@property(nonatomic, weak)id<SubmitCancelProtocol> delegate;
@property(nonatomic, strong)UIButton *submitButton;
@property(nonatomic, strong)UIButton *cancelButton;

+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa;
+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa;

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa tableDelegate:(id<SubmitCancelProtocol>)tableDelegate;
-(void)submit:(id)sender;
-(void)cancel:(id)sender;

@end
