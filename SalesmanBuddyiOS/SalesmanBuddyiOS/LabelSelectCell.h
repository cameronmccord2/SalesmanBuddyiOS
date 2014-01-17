//
//  LabelSelectCell.h
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionAndAnswer.h"

@protocol LabelSelectCellProtocol <NSObject>

-(void)showUIPickerForDelegate:(id<UIPickerViewDelegate, UIPickerViewDataSource>)delegate;

@end

@interface LabelSelectCell : UITableViewCell

@property(nonatomic, strong)UIPickerView *pickerView;
@property(nonatomic, strong)UILabel *label;
@property(nonatomic, strong)UILabel *answerLabel;
@property(nonatomic, strong)NSString *reuseId;
@property(nonatomic, strong)NSArray *options;
//@property(nonatomic, strong)DropdownOption *selectedOption;
@property(nonatomic)id<LabelSelectCellProtocol> labelSelectCellDelegate;

+(NSInteger)getCellHeightForLabelText:(NSString *)labelText selectedOptionText:(NSString *)selectedOptionText;

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id<LabelSelectCellProtocol>)delegate;
-(void)setUpWithLabelText:(NSString *)labelText selectedOptionText:(NSString *)selectedOptionText options:(NSArray *)options;

@end
