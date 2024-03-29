//
//  LicenseListViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDaoV1.h"

@interface LicenseListViewController : UITableViewController <SBDaoV1DelegateProtocol>
@property(nonatomic, strong)NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong)NSMutableArray *licenses;
@property(nonatomic, strong)NSDateFormatter *dateFormatter;

-(id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
