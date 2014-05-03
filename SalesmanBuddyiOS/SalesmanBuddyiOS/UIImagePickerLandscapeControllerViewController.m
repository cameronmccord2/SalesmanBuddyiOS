//
//  UIImagePickerLandscapeControllerViewController.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 5/1/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import "UIImagePickerLandscapeControllerViewController.h"

@interface UIImagePickerLandscapeControllerViewController ()

@end

@implementation UIImagePickerLandscapeControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

@end
