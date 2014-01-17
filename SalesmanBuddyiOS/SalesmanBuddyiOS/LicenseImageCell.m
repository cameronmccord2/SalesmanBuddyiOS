//
//  LicenseImageCell.m
//  SalesmanBuddyiOS
//
//  Created by Cameron McCord on 1/7/14.
//  Copyright (c) 2014 McCord Inc. All rights reserved.
//

#import "LicenseImageCell.h"
#import "SBDaoV1.h"

float static const ImageCompression = 0.1f;// from 0.0 to 1.0
static NSString *licRequiredLabelText = @"Required";

int licLabelLeftPad = 10;
int licLabelTopPad = 10;
int licLabelMaxWidth = 260;
int licTextFieldTopPad = 10;
int licTextFieldLeftPad = 15;
int licTextFieldMaxWidth = 240;
int licTextFieldHeight = 20;
int licBottomPad = 10;
int licRequiredLabelWidth = 300;
int licRequiredLabelLeftPad = 10;
int licRequiredLabelTopPad = 0;

@implementation LicenseImageCell

+(NSInteger)getCellHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    if (qaa.answer.imageDetails.image != nil)
        return 300;
    else
        return 100;
}

+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    return [LicenseImageCell getCellHeightForQuestionAndAnswer:qaa];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Initialization code
        self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 400, 200)];
        
        
        self.retakeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 200, 100)];
        [self.retakeButton setTitle:@"Retake Image" forState:UIControlStateNormal];
        [self.retakeButton setBackgroundColor:[UIColor greenColor]];
        [self.requiredLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.takeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 100, 50)];
        [self.takeButton setTitle:@"Take Image" forState:UIControlStateNormal];
        [self.takeButton setBackgroundColor:[UIColor greenColor]];
        [self.takeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        
        self.requiredLabel = [[UILabel alloc] init];
        [self.requiredLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.requiredLabel setText:licRequiredLabelText];
        [self.requiredLabel setTextAlignment:NSTextAlignmentRight];
        [self.requiredLabel setTextColor:[UIColor blueColor]];
        [self.requiredLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.questionLabel = [[UILabel alloc] init];
        [self.questionLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [self.questionLabel setText:@"Question Text"];
        [self.questionLabel setTextColor:[UIColor blackColor]];
        [self.questionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

-(void)imageData:(NSData *)data{
    self.qaa.answer.imageDetails.image = [[UIImage alloc] initWithData:data];
    [self putImageInView];
}

-(void)putImageInView{
    [self.imageV setImage:self.qaa.answer.imageDetails.image];
    [self.contentView addSubview:self.imageV];
}

-(void)setUpViewNeedToTakeImage{
    [self.contentView addSubview:self.takeButton];
}

-(BOOL)hasImage{
    return (self.qaa.answer.imageDetails.image != nil);
}

-(BOOL)needsToTakeImage{
    return (self.qaa.answer.imageDetails == nil || self.qaa.answer.imageDetails.photoName == nil || self.qaa.answer.imageDetails.bucketId == 0);
}

-(CGRect)requiredLabelRectWithPreviousTopPadding:(CGFloat)previousTopPadding{
    CGSize requiredSize = CGSizeMake(300, 9999);
    CGRect requiredRect = [licRequiredLabelText boundingRectWithSize:requiredSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]} context:nil];
    NSLog(@"thing: %d, %f, %d, %f", licRequiredLabelLeftPad, licLabelTopPad + previousTopPadding + 10, licRequiredLabelWidth, requiredRect.size.height);
    return CGRectMake(licRequiredLabelLeftPad, licLabelTopPad + previousTopPadding + 10, licRequiredLabelWidth, requiredRect.size.height);
}

-(CGRect)questionLabelRect{
    CGSize labelSize = CGSizeMake(licLabelMaxWidth, 9999);
    CGRect textRect = [self.qaa.question.questionTextEnglish boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    CGRect labelRect = CGRectMake(licLabelLeftPad, licLabelTopPad, textRect.size.width, textRect.size.height);
    return labelRect;
}

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa tableDelegate:(id)tableDelegate{
    self.qaa = qaa;
    self.delegate = tableDelegate;
    self.imageSavingStarted = false;
    
    [self.questionLabel setFrame:[self questionLabelRect]];
    [self.questionLabel setText:self.qaa.question.questionTextEnglish];
    
    if (!self.qaa.question.required){
        // make required label rect
        [self.requiredLabel setFrame:[self requiredLabelRectWithPreviousTopPadding:[self questionLabelRect].size.height]];
        [self.contentView addSubview:self.requiredLabel];
    }
    
    if ([self needsToTakeImage])
        [self setUpViewNeedToTakeImage];
    else {
        if ([self hasImage]) // put image on screen
            [self putImageInView];
        else
            [[SBDaoV1 sharedManager] getImageForAnswerId:self.qaa.answer.imageDetails.answerId forDelegate:self];// go get image
    }
}

/*
 -(void)setUpWithLabelText:(NSString *)labelText textFieldText:(NSString *)textFieldText{
 // make text label
 CGSize labelSize = CGSizeMake(licLabelMaxWidth, 9999);
 CGRect textRect = [labelText boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
 CGRect labelRect = CGRectMake(licLabelLeftPad, licLabelTopPad, textRect.size.width, textRect.size.height);
 
 // make required label rect
 CGSize requiredSize = CGSizeMake(licRequiredLabelWidth, 9999);
 CGRect requiredRect = [licRequiredLabelText boundingRectWithSize:requiredSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]} context:nil];
 CGRect requiredLabelRect = CGRectMake(licRequiredLabelLeftPad, licLabelTopPad + labelRect.size.height + licRequiredLabelTopPad, licRequiredLabelWidth, requiredRect.size.height);
 
 // make text field rect
 CGRect textFieldRect = CGRectMake(licTextFieldLeftPad, licLabelTopPad + labelRect.size.height + licRequiredLabelTopPad + requiredRect.size.height + licTextFieldTopPad, licTextFieldMaxWidth, licTextFieldHeight);
 
 // set up labels
 [self.label setFrame:labelRect];
 [self.label setText:labelText];
 [self.requiredLabel setFrame:requiredLabelRect];
 [self.requiredLabel setText:licRequiredLabelText];
 [self.textField setFrame:textFieldRect];
 [self.textField setText:textFieldText];
 }
 */

-(UIButton *)makeTakeImageButton{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 200, 100)];
    [button setBackgroundColor:[UIColor greenColor]];
    [button setTitle:@"Take Image" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchDown];
    return button;
}

-(void)closeImageConnections{
    [self.imageConnection cancel];
}

-(void)imageThen:(NSURLConnectionWithExtras *)connection progress:(NSProgress *)progress{
    self.imageConnection = connection;
}

enum {
    Junk = 0, CantGetLocationTag
};

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
    [self.delegate presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.finishedPhoto = nil;// clear photo so everything waits until it comes back from saving to server
    [self.delegate dismissViewControllerAnimated:YES completion:nil]; //Do this first!
    self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageV setImage:self.image];
    self.imageSavingStarted = true;
    //https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSData_Class/Reference/Reference.html#//apple_ref/c/tdef/NSDataBase64EncodingOptions
    NSData *data = [UIImageJPEGRepresentation(self.image, ImageCompression) base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength];
    NSLog(@"first part: %lu", (unsigned long)data.length);
    [[SBDaoV1 sharedManager] putImage:data forStateId:44 forDelegate:self];
    // set it to nil here?
    
    //image = [ImageHelpers imageWithImage:image scaledToSize:CGSizeMake(480, 640)];
    
    //    [imageView setImage:image];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == CantGetLocationTag) {
        if ([self.delegate respondsToSelector:@selector(setTabBarSelectedIndex:)]) {
            [self.delegate performSelector:@selector(setTabBarSelectedIndex:)];
        }
    }
}

// find out what the cell recieves when it it getting dismissed
-(void)dismissView{
    NSLog(@"closing modal");
    if ([self.delegate respondsToSelector:@selector(dismissAuthModal:)]) {
        if (self.imageConnection != nil) {
            [self.imageConnection cancel];
        }
        
        [self.delegate performSelector:@selector(dismissAuthModal:) withObject:self];
    }else
        NSLog(@"Delegate cannot dismiss details modal");
}

#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
//    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
//    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
