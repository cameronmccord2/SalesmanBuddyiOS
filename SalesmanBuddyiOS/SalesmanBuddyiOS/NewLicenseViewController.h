//
//  NewLicenseViewController.h
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewLicenseViewController : UIViewController

@property(nonatomic, strong)NSManagedObjectContext *context;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
