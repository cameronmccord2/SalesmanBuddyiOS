//
//  LicenseListViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAOManager.h"

@interface LicenseListViewController : UITableViewController <DAOManagerDelegateProtocal>
@property(nonatomic, strong)NSManagedObjectContext *context;
@property(nonatomic, strong)NSMutableArray *licenses;

-(id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
