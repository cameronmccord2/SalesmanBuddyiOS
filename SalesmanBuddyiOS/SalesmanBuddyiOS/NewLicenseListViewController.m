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
#import "SubmitCancelCell.h"

static NSString *CellIdentifier = @"LicenseTableViewCell";
static NSString *kLabelTextFieldCell = @"LabelTextFieldCell";
static NSString *kLabelBoolCell = @"LabelBoolCell";
static NSString *kLicenceImageCell = @"LicenseImageCell";
static NSString *kSubmitCancelCell = @"SubmitCancelCell";

static const NSInteger isImage = 1;
static const NSInteger isText = 3;
static const NSInteger isBool = 2;
static const NSInteger isDropdown = 4;
static const NSInteger isSaveCancel = 5;

@interface NewLicenseListViewController ()

@end

@implementation NewLicenseListViewController

- (instancetype)initWithContext:(NSManagedObjectContext *)managedObjectContext license:(License *)license delegate:(id<SBDaoV1DelegateProtocol>)delegate{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"New License", @"New License");
        self.tabBarItem.image = [UIImage imageNamed:@"licenseList"];
        self.license = license;
        if (self.license == nil) {
            [[SBDaoV1 sharedManager] getQuestionsForDelegate:self];
        }
        self.managedObjectContext = managedObjectContext;
        self.delegate = delegate;
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
    [[self tableView] registerClass:[SubmitCancelCell class] forCellReuseIdentifier:kSubmitCancelCell];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - SBDAO delegate functions

-(void)questions:(NSArray *)questions{
    NSLog(@"recieved questions, count: %ld", (long)[questions count]);
    self.license = [[License alloc] initWithQuestions:questions];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.license) {
        return [self.license.qaas count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    QuestionAndAnswer *qaa = [self.license.qaas objectAtIndex:[indexPath row]];
    switch (qaa.question.questionType) {
        case isImage:
            height = [LicenseImageCell getCellHeightForQuestionAndAnswer:qaa];
            break;
            
        case isBool:
            height = [LabelBoolCell getCellHeightForQuestionAndAnswer:qaa];
            break;
            
        case isText:
            height = [LabelTextFieldCell getCellHeightForQuestionAndAnswer:qaa];
            break;
            
        case isDropdown:
            // nothing for now
            break;
            
        case isSaveCancel:
            height = [SubmitCancelCell getCellHeightForQuestionAndAnswer:qaa];
            break;
            
        default:
            break;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    QuestionAndAnswer *qaa = [self.license.qaas objectAtIndex:[indexPath row]];
    switch (qaa.question.questionType) {
        case isImage:
            height = [LicenseImageCell getEstimatedHeightForQuestionAndAnswer:qaa];
            break;
            
        case isBool:
            height = [LabelBoolCell getEstimatedHeightForQuestionAndAnswer:qaa];
            break;
            
        case isText:
            height = [LabelTextFieldCell getEstimatedHeightForQuestionAndAnswer:qaa];
            break;
            
        case isDropdown:
            // nothing for now
            break;
            
        case isSaveCancel:
            height = [SubmitCancelCell getEstimatedHeightForQuestionAndAnswer:qaa];
            break;
            
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    QuestionAndAnswer *qaa = [self.license.qaas objectAtIndex:[indexPath row]];
    
    switch (qaa.question.questionType) {
        case isImage:{
            LicenseImageCell *lCell = (LicenseImageCell *)[tableView dequeueReusableCellWithIdentifier:kLicenceImageCell forIndexPath:indexPath];
            [lCell setUpWithQuestionAndAnswer:qaa tableDelegate:self];
            cell = lCell;
            break;
        }
        case isBool:{
            LabelBoolCell *lCell = (LabelBoolCell *)[tableView dequeueReusableCellWithIdentifier:kLabelBoolCell forIndexPath:indexPath];
            [lCell setUpWithQuestionAndAnswer:qaa];
            cell = lCell;
            break;
        }
        case isText:{
            LabelTextFieldCell *lCell = (LabelTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:kLabelTextFieldCell forIndexPath:indexPath];
            [lCell setUpWithQuestionAndAnswer:qaa];
            cell = lCell;
            break;
        }
        case isDropdown:
            // nothing for now
            break;
            
        case isSaveCancel:{
            SubmitCancelCell *lCell = (SubmitCancelCell *)[tableView dequeueReusableCellWithIdentifier:kSubmitCancelCell forIndexPath:indexPath];
            [lCell setUpWithQuestionAndAnswer:qaa tableDelegate:self];
            cell = lCell;
            break;
        }
        default:
            break;
    }
    return cell;
}


#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}



-(void)dismissView{
    NSLog(@"closing modal");
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(dismissAuthModal:)]) {
        for (int i = 0; i < [self.license.qaas count]; i++) {
            QuestionAndAnswer *qaa = [self.license.qaas objectAtIndex:i];
            if (qaa.question.questionType == isImage) {
                LicenseImageCell *cell = (LicenseImageCell *)[self tableView:self.tableView cellForRowAtIndexPath:[[NSIndexPath alloc] initWithIndex:i]];
                
            }
        }
        if (self.imageConnection != nil) {
            [self.imageConnection cancel];
        }
        [self.delegate performSelector:@selector(dismissAuthModal:) withObject:self];
    }else
        NSLog(@"Delegate cannot dismiss details modal");
}

-(void)setTabBarSelectedIndex:(NSInteger)index{
    [self.tabBarController setSelectedIndex:index];
}

@end






























