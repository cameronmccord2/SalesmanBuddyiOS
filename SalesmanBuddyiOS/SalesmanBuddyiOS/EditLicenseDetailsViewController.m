//
//  EditLicenseDetailsViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "EditLicenseDetailsViewController.h"
#import "StateQuestions.h"
#import "LoadingModalViewController.h"

@interface EditLicenseDetailsViewController ()

@end

@implementation EditLicenseDetailsViewController

- (id)initWithLicense:(License *)license{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.license = license;
        self.textFields = [[NSMutableArray alloc] init];
        self.licenseImage = nil;
        self.scrollView = nil;
        activeField = nil;
        viewHasLoaded = false;
        self.alert = nil;
        [self registerForKeyboardNotifications];
        [[DAOManager sharedManager] getLicenseImageForLicenseId:self.license.id forDelegate:self];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self buildView];
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
    NSLog(@"activei field set");
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"active field cleared");
    activeField = nil;
    NSString *text = textField.text;
    switch (textField.tag) {
        case LastName:
            self.license.contactInfo.lastName = text;
            break;
            
        case FirstName:
            self.license.contactInfo.firstName = text;
            break;
            
        case Email:
            self.license.contactInfo.email = text;
            break;
            
        case PhoneNumber:
            self.license.contactInfo.phoneNumber = text;
            break;
            
        case StreetAddress:
            self.license.contactInfo.streetAddress = text;
            break;
            
        case City:
            self.license.contactInfo.city = text;
            break;
            
        case Notes:
            self.license.contactInfo.notes = text;
            break;
            
        default:
            for (StateQuestions *sq in self.license.stateQuestionsResponses) {
                if (sq.uniqueTag == textField.tag) {
                    sq.responseText = text;
                    break;
                }
            }
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;{
    // Try to find next responder
    if (textField.tag == Notes) {
        [textField resignFirstResponder];
        return NO;
    }
    NSInteger tag = [self viewAfterTag:textField.tag inArray:self.textFields];
    UIResponder* nextResponder = [textField.superview viewWithTag:tag];
    if (nextResponder != nil) {
        NSLog(@"found next view");
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        NSLog(@"did not find next view");
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

-(NSInteger)viewAfterTag:(NSInteger)tag inArray:(NSArray *)array{
    BOOL takeNextOne = false;
    for (UIView *v in array) {
        if (v.tag == tag) {
            takeNextOne = true;
            NSLog(@"take next one");
        }else if(takeNextOne){
            return v.tag;
        }
    }
    return -1;
}


#pragma mark - Build View Funcions

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
    [self.textFields addObject:textField];
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

enum {
    Junk = 0, LastName, FirstName, Email, PhoneNumber, StreetAddress, City, StateId, Notes, CantGetLocationTag
};

-(void)buildView{
    NSLog(@"building view");
    NSInteger yValue = 15;// initial y value
    float imageViewWidth = [self view].frame.size.width * .5f;
    float imageViewHeight = imageViewWidth;
    float imageViewTopPad = 5;
    float subTitleTopPad = 10;
    float subTitleWidth = 200;
    float subTitleHeight = 30;
    float subTitleLeftPad = 10;
    UIColor *subTitleColor = [UIColor clearColor];
    float TextFieldWidth = [self view].frame.size.width * .7f;
    float TextFieldHeight = 30;
    float TextFieldTopPad = 5;
    float TextFieldLeftPad = 20;
    UIColor *textFieldBackgroundColor = [UIColor grayColor];
    float SaveInfoButtonWidth = 300;
    float SaveInfoButtonHeight = 40;
    float SaveInfoButtonTopPad = 20;
    SEL saveInformationSelector = @selector(saveInformation:);
    UIColor *SaveInfoButtonColor = [UIColor blueColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self view].frame.size.width, [self view].frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    
    yValue = [self makeLabelWithText:@"License Scan" x:0 y:yValue width:[self view].frame.size.width height:30 topPad:0 view:self.scrollView backgroundColor:[UIColor clearColor] alignToCenter:YES];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, yValue + imageViewTopPad, imageViewWidth, imageViewHeight)];
    if (self.licenseImage != nil) {
        [self.imageView setImage:self.licenseImage];
    }
    [self.scrollView addSubview:self.imageView];
    yValue += imageViewTopPad + imageViewHeight;
    
    // State required questions
    if (self.license.stateQuestionsResponses.count > 0) {
        yValue = [self makeLabelWithText:@"Required State Questions" x:subTitleLeftPad y:yValue width:subTitleWidth height:subTitleHeight topPad:subTitleTopPad view:self.scrollView backgroundColor:subTitleColor alignToCenter:NO];
        for (StateQuestions *sq in self.license.stateQuestionsResponses) {
            yValue = [self makeUITextFieldWithPlaceholder:sq.questionText initialText:sq.responseText x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:sq.uniqueTag isLastTextField:NO];
        }
    }
    
    // Build Contact Info Fields
    
    yValue = [self makeLabelWithText:@"Contact Info" x:subTitleLeftPad y:yValue width:subTitleWidth height:subTitleHeight topPad:subTitleTopPad view:self.scrollView backgroundColor:subTitleColor alignToCenter:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"First Name" initialText:self.license.contactInfo.firstName x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:FirstName isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Last Name" initialText:self.license.contactInfo.lastName x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:LastName isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Email" initialText:self.license.contactInfo.email x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:Email isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Phone Number" initialText:self.license.contactInfo.phoneNumber x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:PhoneNumber isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Street Address" initialText:self.license.contactInfo.streetAddress x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:StreetAddress isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"City" initialText:self.license.contactInfo.city x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:City isLastTextField:NO];
    // state
    yValue = [self makeUITextFieldWithPlaceholder:@"Notes" initialText:self.license.contactInfo.notes x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:Notes isLastTextField:YES];
    
    yValue = [self makeUIButtonWithTitle:@"Save Information" x:0 y:yValue width:SaveInfoButtonWidth height:SaveInfoButtonHeight topPad:SaveInfoButtonTopPad view:self.scrollView backgroundColor:SaveInfoButtonColor alignToCenter:YES selectorToDo:saveInformationSelector forControlEvent:UIControlEventTouchDown target:self];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, yValue)];
    self.scrollViewInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [self.scrollView setContentInset:self.scrollViewInsets];
    [self.scrollView setScrollIndicatorInsets:self.scrollViewInsets];
    [self.view addSubview:self.scrollView];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

-(void)imageData:(NSData *)data{
    NSLog(@"got image data");
    NSLog(@"first part: %lu", (unsigned long)data.length);// TODO check on encoding to and from the server****************************************************************************************************************************************************************
    self.licenseImage = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    if (self.imageView != nil) {
        [self.imageView setImage:self.licenseImage];
        NSLog(@"gave image data to image view");
//        [self buildView];
    }
}

-(IBAction)saveInformation:(id)sender{
    NSLog(@"saving information");
    self.loadingModal = [[LoadingModalViewController alloc] initWithTitle:@"Uploading" message:@"Please wait while we upload the photo and data."];
    [self presentViewController:self.loadingModal animated:NO completion:nil];
    [[DAOManager sharedManager] updateLicense:self.license forDelegate:self];
}

-(void)updatedLicense:(License *)updatedLicense{
    [self.loadingModal dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"finished submitting license");
}

//-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
//    if (alertView.tag == CantGetLocationTag) {
//        [self.tabBarController setSelectedIndex:0];
//    }
//}

-(void)showThisModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
