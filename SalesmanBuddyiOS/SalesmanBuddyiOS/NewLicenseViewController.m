//
//  NewLicenseViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/14/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "NewLicenseViewController.h"
//#import "UIView+FLKAutoLayout.h"
#import "StateQuestions.h"


@interface NewLicenseViewController ()

@end

@implementation NewLicenseViewController

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.context = managedObjectContext;
        self.title = NSLocalizedString(@"New License", @"New License");
        self.tabBarItem.image = [UIImage imageNamed:@"newLicence"];
        self.stateQuestions = [[NSArray alloc] init];
        self.textFields = [[NSMutableArray alloc] init];
        self.contactInfo = [[ContactInfo alloc] init];
        self.licenseImage = nil;
        self.imagePickerController = nil;
        self.alert = nil;
        activeField = nil;
        viewHasLoaded = false;
        licenseIsReady = false;
        licenseImageSavingStarted = false;
        [self registerForKeyboardNotifications];
        [[DAOManager sharedManager] getStateQuestionsForStateId:44 forDelegate:self];
    }
    return self;
}

-(void)resetView{
    self.textFields = [[NSMutableArray alloc] init];
    self.contactInfo = [[ContactInfo alloc] init];
    self.licenseImage = nil;
    self.alert = nil;
    viewHasLoaded = false;
    licenseIsReady = false;
    licenseImageSavingStarted = false;
    activeField = nil;
    self.imagePickerController = nil;
    for (StateQuestions *sq in self.stateQuestions) {
        sq.responseBool = 0;
        sq.responseText = @"";
    }
    [self buildView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewHasLoaded = true;
    if (self.stateQuestions.count > 0) {
        [self buildView];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Location services NOT enabled" message:@"Scanning new licenses requires saving your current location for security purposes. Please go to Settings-Privacy-Location Services and enable this app's location privileges." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.alert.tag = CantGetLocationTag;
        [self.alert show];
    }
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
            self.contactInfo.lastName = text;
            break;
            
        case FirstName:
            self.contactInfo.firstName = text;
            break;
            
        case Email:
            self.contactInfo.email = text;
            break;
            
        case PhoneNumber:
            self.contactInfo.phoneNumber = text;
            break;
            
        case StreetAddress:
            self.contactInfo.streetAddress = text;
            break;
            
        case City:
            self.contactInfo.city = text;
            break;
            
        case Notes:
            self.contactInfo.notes = text;
            break;
            
        default:
            for (StateQuestions *sq in self.stateQuestions) {
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
    UIResponder* nextResponder = [textField.superview viewWithTag:[self viewAfterTag:textField.tag inArray:self.textFields]];
    if (nextResponder) {
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

-(NSInteger)makeUITextFieldWithPlaceholder:(NSString *)placeholder x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height topPad:(NSInteger)topPad view:(UIScrollView *)view backgroundColor:(UIColor *)color alignToCenter:(BOOL)alignToCenter uniqueTag:(NSInteger)uniqueTag isLastTextField:(BOOL)lastTextField{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x, y + topPad, width, height)];
    [textField setPlaceholder:placeholder];
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
    float takePhotoButtonTopPad = 10;
    float takePhotoButtonWidth = 200;
    float takePhotoButtonHeight = 40;
    UIColor *takePhotoButtonColor = [UIColor greenColor];
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
    float SaveInfoButtonWidth = 150;
    float SaveInfoButtonHeight = 40;
    float SaveInfoButtonTopPad = 20;
    SEL saveInformationSelector = @selector(saveInformation:);
    UIColor *SaveInfoButtonColor = [UIColor blueColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self view].frame.size.width, [self view].frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];

    
    yValue = [self makeLabelWithText:@"New License Scan" x:0 y:yValue width:[self view].frame.size.width height:30 topPad:0 view:self.scrollView backgroundColor:[UIColor clearColor] alignToCenter:YES];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, yValue + imageViewTopPad, imageViewWidth, imageViewHeight)];
    [self.scrollView addSubview:self.imageView];
    yValue += imageViewTopPad + imageViewHeight;
    
    yValue = [self makeUIButtonWithTitle:@"Take License Photo" x:10 y:yValue width:takePhotoButtonWidth height:takePhotoButtonHeight topPad:takePhotoButtonTopPad view:self.scrollView backgroundColor:takePhotoButtonColor alignToCenter:NO selectorToDo:@selector(takePicture:) forControlEvent:UIControlEventTouchDown target:self];
    
    // State required questions
    if (self.stateQuestions.count > 0) {
        yValue = [self makeLabelWithText:@"Required State Questions" x:subTitleLeftPad y:yValue width:subTitleWidth height:subTitleHeight topPad:subTitleTopPad view:self.scrollView backgroundColor:subTitleColor alignToCenter:NO];
        for (StateQuestions *sq in self.stateQuestions) {
            yValue = [self makeUITextFieldWithPlaceholder:sq.questionText x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:sq.uniqueTag isLastTextField:NO];
        }
    }
    
    // Build Contact Info Fields
    
    yValue = [self makeLabelWithText:@"Contact Info" x:subTitleLeftPad y:yValue width:subTitleWidth height:subTitleHeight topPad:subTitleTopPad view:self.scrollView backgroundColor:subTitleColor alignToCenter:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"First Name" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:FirstName isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Last Name" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:LastName isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Email" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:Email isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Phone Number" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:PhoneNumber isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"Street Address" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:StreetAddress isLastTextField:NO];
    yValue = [self makeUITextFieldWithPlaceholder:@"City" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:City isLastTextField:NO];
    // state
    yValue = [self makeUITextFieldWithPlaceholder:@"Notes" x:TextFieldLeftPad y:yValue width:TextFieldWidth height:TextFieldHeight topPad:TextFieldTopPad view:self.scrollView backgroundColor:textFieldBackgroundColor alignToCenter:NO uniqueTag:Notes isLastTextField:YES];
    
    yValue = [self makeUIButtonWithTitle:@"Clear" x:0 y:yValue width:SaveInfoButtonWidth * .5f height:SaveInfoButtonHeight topPad:SaveInfoButtonTopPad view:self.scrollView backgroundColor:[UIColor redColor] alignToCenter:YES selectorToDo:@selector(resetView) forControlEvent:UIControlEventTouchDown target:self];
    
    yValue = [self makeUIButtonWithTitle:@"Save Information" x:0 y:yValue width:SaveInfoButtonWidth height:SaveInfoButtonHeight topPad:SaveInfoButtonTopPad view:self.scrollView backgroundColor:SaveInfoButtonColor alignToCenter:YES selectorToDo:saveInformationSelector forControlEvent:UIControlEventTouchDown target:self];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, yValue)];
    self.scrollViewInsets = UIEdgeInsetsMake(0.0, 0.0, 56.0, 0.0);
    [self.scrollView setContentInset:self.scrollViewInsets];
    [self.scrollView setScrollIndicatorInsets:self.scrollViewInsets];
    [self.view addSubview:self.scrollView];
}

-(void)stateQuestions:(NSArray *)stateQuestions{
    NSLog(@"recieved state questions, %ld", (long)stateQuestions.count);
    self.stateQuestions = stateQuestions;
    if (viewHasLoaded) {
        [self buildView];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

-(IBAction)saveInformation:(id)sender{
    NSLog(@"saving information");
    BOOL stateQuestionsAnswered = false;
    for (StateQuestions *sq in self.stateQuestions) {
        if (sq.responseText.length > 0) {
            stateQuestionsAnswered = true;
        }else{
            stateQuestionsAnswered = false;
            break;
        }
    }
    if (self.licenseImage == nil || !stateQuestionsAnswered) {
        self.alert = [[UIAlertView alloc] initWithTitle:@"Submission Error" message:@"Please be sure to take an image and answer the required state questions before submitting." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.alert show];
        self.license = nil;
        return;
    }else{
        License *l = [[License alloc] init];
        l.stateId = 44;
        self.contactInfo.stateId = 44;
        l.contactInfo = self.contactInfo;
        CLLocationCoordinate2D coordinate = [[DAOManager sharedManager] getLocation];
        l.longitude = coordinate.longitude;
        l.latitude = coordinate.latitude;
        l.stateQuestionsResponses = self.stateQuestions;
        self.license = l;
        if (self.licenseImage != nil) {
            self.loadingModal = [[LoadingModalViewController alloc] initWithTitle:@"Uploading" message:@"Please wait while we upload the photo and data." useUploadProgress:YES];
            [self presentViewController:self.loadingModal animated:NO completion:nil];
            if (self.finishedPhoto != nil) {
                [self uploadLicense];
            }else{
                licenseIsReady = YES;
            }
        }else
            NSLog(@"waiting for photo to upload");
    }
}

-(void)uploadLicense{
    if (self.loadingModal == nil) {
        self.loadingModal = [[LoadingModalViewController alloc] initWithTitle:@"Uploading" message:@"Please wait while we upload the photo and data." useUploadProgress:YES];
        [self presentViewController:self.loadingModal animated:NO completion:nil];
    }
    self.license.photo = self.finishedPhoto.filename;
    [[DAOManager sharedManager] putLicense:self.license forDelegate:self];
}

-(void)finishedPhoto:(FinishedPhoto *)finishedPhoto{
    NSLog(@"finished putting photo, %@", finishedPhoto.filename);
    self.finishedPhoto = finishedPhoto;
    if (licenseIsReady) {
        [self uploadLicense];
    }
}

-(void)finishedSubmitLicense:(License *)license{
    [self.loadingModal dismissViewControllerAnimated:NO completion:nil];
    [self resetView];
    [self.tabBarController setSelectedIndex:0];
    NSLog(@"finished submitting license");
}

-(IBAction)takePicture:(id)sender{
    if (!self.imagePickerController) {
        // If our device has a camera, we want to take a picture, otherwise, we just pick from
        // photo library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePickerController = [[UIImagePickerController alloc] init];
            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        }else{
            self.alert = [[UIAlertView alloc] initWithTitle:@"Camera Error" message:@"We are unable to access your camera. Please try this on a device with a camera." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self.alert show];
            return;
        }
        [self.imagePickerController setDelegate:self];
    }
    // Place image picker on the screen
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.finishedPhoto = nil;// clear photo so everything waits until it comes back from saving to server
    [self dismissViewControllerAnimated:YES completion:nil]; //Do this first!
    self.licenseImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageView setImage:self.licenseImage];
    licenseImageSavingStarted = true;
    //https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/Reference/Reference.html#//apple_ref/c/tdef/NSDataBase64EncodingOptions
    NSData *data = [UIImageJPEGRepresentation(self.licenseImage, 1.0) base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength];
    NSLog(@"first part: %lu", (unsigned long)data.length);
    [[DAOManager sharedManager] putImage:data forStateId:44 forDelegate:self];
    // set it to nil here?
    
    //image = [ImageHelpers imageWithImage:image scaledToSize:CGSizeMake(480, 640)];
    
    //    [imageView setImage:image];
}

-(void)connectionProgress:(NSNumber *)progress total:(NSNumber *)total{
    if (self.loadingModal != nil) {
        if([self.loadingModal respondsToSelector:@selector(connectionProgress:total:)]){
            [self.loadingModal performSelector:@selector(connectionProgress:total:) withObject:progress withObject:total];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == CantGetLocationTag) {
        [self.tabBarController setSelectedIndex:0];
    }
}

-(void)showThisModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissThisViewController:(UIViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
