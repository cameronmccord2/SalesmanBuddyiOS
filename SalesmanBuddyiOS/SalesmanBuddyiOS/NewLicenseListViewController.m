//
//  NewLicenseListViewController.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import "NewLicenseListViewController.h"
#import "QuestionAndAnswer.h"
#import "LabelTextFieldCell.h"
#import "LabelBoolCell.h"
#import "LicenseImageCell.h"

NSString *CellIdentifier = @"LicenseTableViewCell";
NSString *kLabelTextFieldCell = @"LabelTextFieldCell";
NSString *kLabelBoolCell = @"LabelBoolCell";
NSString *kLicenceImageCell = @"LicenseImageCell";

@interface NewLicenseListViewController ()

@end

@implementation NewLicenseListViewController

-(instancetype)initWithLicense:(License *)license{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.license = license;
        if (self.license == nil) {
            [[SBDaoV1 sharedManager] getQuestionsForDelegate:self];
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 52, 0);
    self.tableView.contentInset = inset;
    
    // custom cells
    [[self tableView] registerClass:[LabelTextFieldCell class] forCellReuseIdentifier:kLabelTextFieldCell];
    [[self tableView] registerClass:[LabelBoolCell class] forCellReuseIdentifier:kLabelBoolCell];
    [[self tableView] registerClass:[LicenseImageCell class] forCellReuseIdentifier:kLicenceImageCell];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - SBDAO delegate functions

-(void)questions:(NSArray *)questions{
    self.license = [[License alloc] initWithQuestions:questions];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.license.qaas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    QuestionAndAnswer *qaa = [self.license.qaas objectAtIndex:[indexPath row]];
    if(qaa.question.questionIsText){
        height = [LabelTextFieldCell getCellHeightForLabelText:qaa.question.questionTextEnglish];
    }else if(qaa.question.questionIsBool){
        height = [LabelBoolCell getCellHeightForLabelText:qaa.question.questionTextEnglish];
    }
//    else if(qaa.question.questionIsImage){
//        
//    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    QuestionAndAnswer *qaa = [self.license.qaas objectAtIndex:[indexPath row]];
    if(qaa.question.questionIsBool){
        LabelBoolCell *lCell = (LabelBoolCell *)[tableView dequeueReusableCellWithIdentifier:kLabelBoolCell forIndexPath:indexPath];
//        if(lCell == nil || lCell == Nil)
//            lCell = [[LabelBoolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLabelTextFieldCell];
        [lCell setUpWithLabelText:qaa.question.questionTextEnglish boolSetTo:qaa.answer.answerBool];
        cell = lCell;
    }else if(qaa.question.questionIsText){
        LabelTextFieldCell *lCell = (LabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:kLabelTextFieldCell forIndexPath:indexPath];
        if (lCell == nil || lCell == Nil)// this will never get hit in ios7
            lCell = [[LabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLabelTextFieldCell];
        [lCell setUpWithLabelText:qaa.question.questionTextEnglish textFieldText:qaa.answer.answerText];
        cell = lCell;
    }
//    else if(qaa.question.questionIsImage){
//        
//    }
    return cell;
}


#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end






























