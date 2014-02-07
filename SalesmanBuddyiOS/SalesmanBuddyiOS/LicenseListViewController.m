//
//  LicenseListViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "LicenseListViewController.h"
#import "License.h"
#import "LicenseTableViewCell.h"
#import "LabelBoolCell.h"
#import "LabelTextFieldCell.h"
#import "QuestionAndAnswer.h"
#import "NewLicenseListViewController.h"

@interface LicenseListViewController ()

@end

NSString *CellIdentifier = @"LicenseTableViewCell";
NSString *kLabelTextFieldCell = @"LabelTextFieldCell";
NSString *kLabelBoolCell = @"LabelBoolCell";
NSString *text = @"asf asdf ;lkjasdf asdf;lkjasdf qpoiu poiuqwerpoiuqwer qwpoeiru qweporipoiuqwerasdfasdfasdfasdfasdfasdf opiuei  qwerp iqpoiue poi wqpeoriupoie  eiur qwer,zxc qer zxcv wer  c .e c    eqwr xc easdfasdf";

@implementation LicenseListViewController

-(id)initWithContext:(NSManagedObjectContext *)managedObjectContext{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        self.managedObjectContext = managedObjectContext;
        self.title = NSLocalizedString(@"Licenses", @"Licenses");
        self.tabBarItem.image = [UIImage imageNamed:@"licenseList"];
        self.licenses = [[NSMutableArray alloc] init];
//        self.dateFormatter = [NSDateFormatter datreFormatFromTemplate:<#(NSString *)#> options:<#(NSUInteger)#> locale:<#(NSLocale *)#>
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LicenseTableViewCellGUI" owner:self options:nil];
//        [self.tableView registerNib:(UINib *)[nib firstObject] forCellReuseIdentifier:CellIdentifier];
//        [self.tableView registerClass:[LicenseTableViewCell class] forCellReuseIdentifier:CellIdentifier];
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
    
//    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"LicenseTableViewCellGUI" owner:self options:nil];
//    UINib *nib = (UINib *)[nibs firstObject];
//    [[self tableView] registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [[SBDaoV1 sharedManager] getLicensesForDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - DAOManagerDelegateProtocal functions

-(void)licenses:(NSMutableArray *)licenses{
    NSLog(@"recieved licenses, count: %ld", (long)[licenses count]);
    self.licenses = licenses;
    [self.tableView reloadData];
}


#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}







-(Answer *)getFirstNameAnswer:(NSArray *)qaas{
    return [self getQaaWithQuestionText:@"First Name" fromList:qaas].answer;
}

-(Answer *)getLastNameAnswer:(NSArray *)qaas{
    return [self getQaaWithQuestionText:@"Last Name" fromList:qaas].answer;
}

-(QuestionAndAnswer *)getQaaWithQuestionText:(NSString *)questionText fromList:(NSArray *)qaas{
    for (QuestionAndAnswer *qaa in qaas) {
        if ([qaa.question.questionTextEnglish isEqualToString:questionText]) {
            return qaa;
        }
    }
    return nil;
}
















#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.licenses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LicenseTableViewCellGUI" owner:self options:nil];
    NSLog(@"count: %ld", (long)nib.count);
    NSLog(@"setting up cell");
    LicenseTableViewCell *cell = (LicenseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSLog(@"made new cell, this actually got hit!!!!!!!!!!!!!!!!!!!!");
        cell = [[LicenseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.name = [[UILabel alloc] initWithFrame:CGRectMake(7, 2, 206, 21)];
        [cell.contentView addSubview:cell.name];
        
        cell.details = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 206, 21)];
        [cell.details setFont:[UIFont systemFontOfSize:14.0]];
        [cell.contentView addSubview:cell.details];
        
//        cell.flag = [[UIImageView alloc] initWithFrame:CGRectMake(221, 0, 49, 43)];
//        [cell.contentView addSubview:cell.flag];
        
//        UIImageView *accesoryView = [[UIImageView alloc] initWithFrame:CGRectMake(273, 0, 47, 43)];
//        [accesoryView setImage:[UIImage imageNamed:@"blueArrow.png"]];
//        [cell.contentView addSubview:accesoryView];
    }
    
    // Fix the flag thing on all cells
    int index = (int)[indexPath row];
    License *l = [self.licenses objectAtIndex:index];
    [cell.name setText:[NSString stringWithFormat:@"%@, %@", [self getLastNameAnswer:l.qaas].answerText, [self getFirstNameAnswer:l.qaas].answerText]];
    [cell.details setText:[NSString stringWithFormat:@"%@,  ID: %@", l.created, @"12345"]];
    BOOL isFlagged = true;
    if (isFlagged)
        [cell.flag setImage:[UIImage imageNamed:@"flagRed.png"]];
    else
        [cell.flag setImage:[UIImage imageNamed:@"flagGrey.png"]];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        License *l = [self.licenses objectAtIndex:indexPath.row];
        NSLog(@"deleting license with id: %ld", (long)l.id);
        [self.licenses removeObjectAtIndex:indexPath.row];
        [[SBDaoV1 sharedManager] deleteLicenseById:l.id forDelegate:self];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)deletedLicenseWithId:(DeleteLicenseResponse *)deleteLicenseResponse{
    if (deleteLicenseResponse.success == 1) {
        NSLog(@"deleted license with id: %ld, message: %@", (long)deleteLicenseResponse.licenseId, deleteLicenseResponse.message);
    }else{
        NSLog(@"failed to delete license with id: %ld, message: %@", (long)deleteLicenseResponse.licenseId, deleteLicenseResponse.message);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewLicenseListViewController *nllvc = [[NewLicenseListViewController alloc] initWithContext:self.managedObjectContext license:[self.licenses objectAtIndex:indexPath.row] delegate:self];
    [self presentViewController:nllvc animated:YES completion:nil];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
