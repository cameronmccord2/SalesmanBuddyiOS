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
        [self registerForKeyboardNotifications];
        self.managedObjectContext = managedObjectContext;
        self.delegate = delegate;
        self.title = NSLocalizedString(@"New License", @"New License");
        self.tabBarItem.image = [UIImage imageNamed:@"licenseList"];
        self.license = license;
        self.isTabInstance = false;
        
        if (self.license == nil) {
            NSLog(@"license is null");
            self.isTabInstance = true;
            [[SBDaoV1 sharedManager] getQuestionsForDelegate:self];
        }else{
            NSLog(@"license isnt null");
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 50, 0);
    self.tableView.contentInset = inset;
    
    // custom cells
    [[self tableView] registerClass:[LabelTextFieldCell class] forCellReuseIdentifier:kLabelTextFieldCell];
    [[self tableView] registerClass:[LabelBoolCell class] forCellReuseIdentifier:kLabelBoolCell];
    [[self tableView] registerClass:[LicenseImageCell class] forCellReuseIdentifier:kLicenceImageCell];
    [[self tableView] registerClass:[SubmitCancelCell class] forCellReuseIdentifier:kSubmitCancelCell];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.alert = [[UIAlertView alloc] initWithTitle:@"Camera Error" message:@"We are unable to access your camera. Please try this on a device with a camera." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.alert.tag = CantUseCameraTag;
        [self.alert show];
    }else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Location services NOT enabled" message:@"Scanning new licenses requires saving your current location for security purposes. Please go to Settings-Privacy-Location Services and enable this app's location privileges." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.alert.tag = CantGetLocationTag;
        [self.alert show];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark - SBDAO delegate functions

-(void)questions:(NSArray *)questions{
    NSLog(@"recieved questions, count: %ld", (long)[questions count]);
    self.license = [[License alloc] initWithQuestions:questions];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
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
    [cell setTag:[indexPath row]];
    return cell;
}

-(void)finishedSubmitLicense:(License *)license{
    if(self.isTabInstance){
        [[SBDaoV1 sharedManager] getQuestionsForDelegate:self];
    }
}


#pragma mark - SubmitCancelProtocol functions

-(void)submit{
    NSLog(@"submit recieved");
    for (QuestionAndAnswer *qaa in self.license.qaas) {
        NSLog(@"Q: %@, A: %@", qaa.question.questionTextEnglish, qaa.answer.answerText);
    }
    CLLocationCoordinate2D coordinate = [[SBDaoV1 sharedManager] getLocation];
    self.license.longitude = coordinate.longitude;
    self.license.latitude = coordinate.latitude;
    [[SBDaoV1 sharedManager] putLicense:self.license forDelegate:self];
}

-(void)cancel{
    NSLog(@"cancel recieved");
    if (self.isTabInstance) {
        NSLog(@"tab instance");
        // reset questions
        for (QuestionAndAnswer *qaa in self.license.qaas) {
            qaa.answer.answerText = @"";
            qaa.answer.answerBool = NO;
            if(qaa.answer.answerType == isImage){
                qaa.answer.imageDetails = [[ImageDetails alloc] init];
            }
        }
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }else{      // unload view
        [self.delegate dismissAuthModal:self];
    }
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




#pragma mark - Keyboard stuff

- (void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification{
    NSLog(@"will scroll");
    [self setKeyboardInsets];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    [self setNoKeyboardInsets];
}

//-(NSInteger)viewAfterTag:(NSInteger)tag inArray:(NSArray *)array{
//    BOOL takeNextOne = false;
//    for (UIView *v in array) {
//        if (v.tag == tag) {
//            takeNextOne = true;
//            NSLog(@"take next one");
//        }else if(takeNextOne){
//            return v.tag;
//        }
//    }
//    return -1;
//}

-(void)setKeyboardInsets{
    NSLog(@"%f", self.tableView.contentInset.bottom);
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, self.tableView.contentInset.bottom - 50.0f, 0);
    self.tableView.contentInset = inset;
    NSLog(@"%f", self.tableView.contentInset.bottom);
}

-(void)setNoKeyboardInsets{
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 266, 0);// i dont know why this has to be so large 266, shouldnt it be more like 50?
    self.tableView.contentInset = inset;
}

enum {
    Junk = 0, CantUseCameraTag, CantGetLocationTag
};

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
#warning change this to allow for modal and for tab types
    if (alertView.tag == CantUseCameraTag) {
        [self setTabBarSelectedIndex:0];
    }else if (alertView.tag == CantGetLocationTag) {
        [self.tabBarController setSelectedIndex:0];
    }
}

@end






























