//
//  LabelSelectCell.m
//  TruckerBid
//
//  Created by Cameron McCord on 12/25/13.
//  Copyright (c) 2013 Cameron McCord. All rights reserved.
//

#import "LabelSelectCell.h"

int lscLabelLeftPad = 10;
int lscLabelTopPad = 10;
int lscLabelMaxWidth = 260;
int lscAnswerLabelTopPad = 10;
int lscAnswerLabelLeftPad = 15;
int lscAnswerLabelMaxWidth = 240;
int lscBottomPad = 10;

@implementation LabelSelectCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id<LabelSelectCellProtocol>)delegate{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.reuseId = reuseIdentifier;
        self.options = [[NSArray alloc] init];
        self.label = [[UILabel alloc] init];
        [self.label setTextColor:[UIColor blackColor]];
        [self.label setBackgroundColor:[UIColor colorWithHue:32 saturation:100 brightness:63 alpha:1]];
        [self.label setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.label.numberOfLines = 0;
//        [self.contentView addSubview:self.label];
        
        self.answerLabel = [[UILabel alloc] init];
        [self.answerLabel setTextColor:[UIColor blackColor]];
        [self.answerLabel setBackgroundColor:[UIColor blackColor]];
        [self.answerLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [self.answerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.answerLabel.numberOfLines = 0;
        [self.contentView addSubview:self.answerLabel];
        
//        UILabel *l = [[UILabel alloc] init];
//        [l setText:@"Temp Text"];
//        [self.contentView addSubview:l];
        self.labelSelectCellDelegate = delegate;
        self.pickerView = [UIPickerView new];
    }
//    else
//        NSLog(@"self error");
    return self;
}

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa{
//    NSLog(@"set up with question and answer");
//    [self setUpWithLabelText:qaa.question.questionTextEnglish selectedOptionText:qaa.answer.answerText options:qaa.question.dropdownOptions];
}

-(void)setUpWithLabelText:(NSString *)labelText selectedOptionText:(NSString *)selectedOptionText options:(NSArray *)options{
    self.options = options;
    
    // Question Label
    CGSize labelSize = CGSizeMake(lscLabelMaxWidth, 9999);
    CGRect textRect = [labelText boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    CGRect labelRect = CGRectMake(lscLabelLeftPad, lscLabelTopPad, textRect.size.width, textRect.size.height);
    
    [self.label setFrame:labelRect];
    [self.label setText:labelText];
    
    // Answer Label
    NSString *answerLabelText = [NSString stringWithFormat:@"%@", selectedOptionText];
    if ([selectedOptionText length] == 0){
        answerLabelText = [NSString stringWithFormat:@"Select Option"];
        [self.answerLabel setTextColor:[UIColor grayColor]];
    }
    
    CGSize answerLabelSize = CGSizeMake(lscAnswerLabelMaxWidth, 9999);
    CGRect answerTextRect = [answerLabelText boundingRectWithSize:answerLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil];
    CGRect answerLabelRect = CGRectMake(lscAnswerLabelLeftPad, lscAnswerLabelTopPad + labelRect.size.height + lscLabelTopPad, answerTextRect.size.width, answerTextRect.size.height);
    
    [self.answerLabel setFrame:answerLabelRect];
    [self.answerLabel setText:@"text"];
    NSLog(@"set answer text, %@", answerLabelText);
}

+(NSInteger)getCellHeightForLabelText:(NSString *)labelText selectedOptionText:(NSString *)selectedOptionText{
    CGSize labelSize = CGSizeMake(lscLabelMaxWidth, 9999);
    CGRect textRect = [labelText boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    
    NSString *answerLabelText = [NSString stringWithFormat:@"%@", selectedOptionText];
    if ([selectedOptionText length] == 0)
        answerLabelText = [NSString stringWithFormat:@"Select Option"];
    
    CGSize answerLabelSize = CGSizeMake(lscAnswerLabelMaxWidth, 9999);
    CGRect answerTextRect = [answerLabelText boundingRectWithSize:answerLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil];
    int height = lscLabelTopPad + textRect.size.height + lscAnswerLabelTopPad + answerTextRect.size.height + lscBottomPad;
    NSLog(@"got height for cell: %ld", (long)height);
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
//    SEL showUIPickerSelector = @selector(showUIPickerForDelegate:);
//    NSLog(@"set selected");
//    if ([self.labelSelectCellDelegate respondsToSelector:showUIPickerSelector]) {
//        [self.labelSelectCellDelegate performSelector:showUIPickerSelector withObject:self];
//    }else
//        NSLog(@"cant respond to selector: %@, delegate: %@", NSStringFromSelector(showUIPickerSelector), self.labelSelectCellDelegate);
}

//#pragma mark - UIPickerView datasource functions
//
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
//    return 1;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return [self.options count];
//}
//
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    DropdownOption *dropdownOption = [self.options objectAtIndex: row];
//    return dropdownOption.optionText;
//}
//
//-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    int sectionWidth = 300;
//    return sectionWidth;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    [self.answerLabel setTextColor:[UIColor blackColor]];
//    self.selectedOption = [self.options objectAtIndex:row];
//}


@end
