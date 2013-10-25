//
//  LicenseListViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "LicenseListViewController.h"
#import "License.h"
#import "EditLicenseDetailsViewController.h"

@interface LicenseListViewController ()

@end

@implementation LicenseListViewController

-(id)initWithContext:(NSManagedObjectContext *)managedObjectContext{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self){
        self.context = managedObjectContext;
        self.title = NSLocalizedString(@"Licenses", @"Licenses");
        self.tabBarItem.image = [UIImage imageNamed:@"licenseList"];
        self.licenses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [[DAOManager sharedManager] getLicensesForDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - DAOManagerDelegateProtocal functions

-(void)licenses:(NSMutableArray *)licenses{
    NSLog(@"recieved licenses");
    self.licenses = licenses;
    [self.tableView reloadData];
}

-(void)showThisModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}
























#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.licenses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"setting up cell");
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    int index = [indexPath row];
    License *l = [self.licenses objectAtIndex:index];
    cell.textLabel.text = l.contactInfo.lastName;
    // Configure the cell...
    
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
        [[DAOManager sharedManager] deleteLicenseById:l.id forDelegate:self];
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
    EditLicenseDetailsViewController *eldvc = [[EditLicenseDetailsViewController alloc] initWithLicense:[self.licenses objectAtIndex:indexPath.row]];
    [self presentViewController:eldvc animated:YES completion:nil];
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
