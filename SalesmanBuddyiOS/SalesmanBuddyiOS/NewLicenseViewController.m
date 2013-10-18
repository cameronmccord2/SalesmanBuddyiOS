//
//  NewLicenseViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "NewLicenseViewController.h"

@interface NewLicenseViewController ()

@end

@implementation NewLicenseViewController

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.context = managedObjectContext;
        self.title = NSLocalizedString(@"New License", @"New License");
        self.tabBarItem.image = [UIImage imageNamed:@"newLicence"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
