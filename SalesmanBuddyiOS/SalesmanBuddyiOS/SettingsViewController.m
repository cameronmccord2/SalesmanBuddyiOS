//
//  SettingsViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/25/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"licenseList"];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self buildView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buildView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self view].frame.size.width, [self view].frame.size.height)];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    
    NSInteger yValue = [self makeLabelWithText:@"Settings" x:0 y:0 width:[self view].frame.size.width height:40 topPad:10 view:self.scrollView backgroundColor:[UIColor clearColor] alignToCenter:YES];
    
    yValue = [self makeUIButtonWithTitle:@"Logout User" x:10 y:yValue width:200 height:30 topPad:20 view:self.scrollView backgroundColor:[UIColor greenColor] alignToCenter:NO selectorToDo:@selector(logoutUser:) forControlEvent:UIControlEventTouchDown target:self];
    
    yValue = [self makeUITextFieldWithPlaceholder:@"Feedback" initialText:@"" x:10 y:yValue width:[self view].frame.size.width * 0.8f height:30 topPad:30 view:self.scrollView backgroundColor:[UIColor grayColor] alignToCenter:NO uniqueTag:Feedback isLastTextField:YES];
    
    yValue = [self makeUIButtonWithTitle:@"Submit Feedback" x:10 y:yValue width:150 height:30 topPad:10 view:self.scrollView backgroundColor:[UIColor greenColor] alignToCenter:NO selectorToDo:@selector(submitFeedback) forControlEvent:UIControlEventTouchDown target:self];
    
    self.scrollViewInsets = UIEdgeInsetsMake(0.0, 0.0, 56.0, 0.0);
    [self.scrollView setContentInset:self.scrollViewInsets];
    [self.scrollView setContentSize:CGSizeMake([self view].frame.size.width, yValue)];
    [self.view addSubview:self.scrollView];
}

-(void)submitFeedback{
    NSLog(@"Submitting feedback");
}

-(void)logoutUser:(id)sender{
    NSLog(@"logging out user");
    [[DAOManager sharedManager] signOutOfGoogle];
    [self.tabBarController setSelectedIndex:0];
}

enum {
    Logout, Feedback
};

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
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    NSLog(@"%f, %f", aRect.size.height, activeField.frame.origin.y);
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        NSLog(@"scrolling");
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }else{
        NSLog(@"no need to scroll, %f, %f", aRect.size.height, activeField.frame.origin.y);
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    self.scrollView.contentInset = self.scrollViewInsets;
    self.scrollView.scrollIndicatorInsets = self.scrollViewInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    NSLog(@"activei field set");
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
//    NSLog(@"active field cleared");
    activeField = nil;
    NSString *text = textField.text;
    switch (textField.tag) {
        case Feedback:
            self.feedback = text;
            break;
            
        default:
            
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;{
    [textField resignFirstResponder];
    return NO; // We do not want UITextField to insert line-breaks.
}

-(NSInteger)makeLabelWithText:(NSString *)text x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height topPad:(NSInteger)topPad view:(UIScrollView *)view backgroundColor:(UIColor *)color alignToCenter:(BOOL)alignToCenter{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x, y + topPad, width, height)];
    [view addSubview:title];
    [title setBackgroundColor:color];
    [title setText:text];
    if (alignToCenter) {
        [title setTextAlignment:NSTextAlignmentCenter];
        //        [title alignCenterXWithView:view predicate:nil];
    }
    return y + height + topPad;
}

-(NSInteger)makeUITextFieldWithPlaceholder:(NSString *)placeholder initialText:(NSString *)initalText x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height topPad:(NSInteger)topPad view:(UIScrollView *)view backgroundColor:(UIColor *)color alignToCenter:(BOOL)alignToCenter uniqueTag:(NSInteger)uniqueTag isLastTextField:(BOOL)lastTextField{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x, y + topPad, width, height)];
    [textField setPlaceholder:placeholder];
    [textField setText:initalText];
    [textField setBackgroundColor:color];
    [textField setTag:uniqueTag];
    [textField setDelegate:self];
    if (!lastTextField)
        [textField setReturnKeyType:UIReturnKeyNext];
    else
        [textField setReturnKeyType:UIReturnKeyDone];
    if (alignToCenter) {
        [textField setCenter:CGPointMake(self.view.center.x, y + topPad + height * .5f)];
        //        [textField alignCenterXWithView:view predicate:nil];
    }
    [view addSubview:textField];
    return y + height + topPad;
}

-(NSInteger)makeUIButtonWithTitle:(NSString *)title x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height topPad:(NSInteger)topPad view:(UIScrollView *)view backgroundColor:(UIColor *)color alignToCenter:(BOOL)alignToCenter selectorToDo:(SEL)selector forControlEvent:(UIControlEvents)controlEvent target:(id)target{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y + topPad, width, height)];
    [button setBackgroundColor:color];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:controlEvent];
    if (alignToCenter) {
        [button setCenter:CGPointMake(self.view.center.x, y + topPad + height * .5f)];
    }
    [view addSubview:button];
    return y + topPad + height;
}

-(void)showThisModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissThisViewController:(UIViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
