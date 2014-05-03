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

#define SCALE_IMAGE_BY 10
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
    if (qaa.answer.imageDetails.image != nil){
//        NSLog(@"%ld", (long)qaa.answer.imageDetails.image.size.height);
        return qaa.answer.imageDetails.image.size.height/SCALE_IMAGE_BY + 25;
    }
    
    else
        return 260;// 210 if image divided by 16
}

+(NSInteger)getEstimatedHeightForQuestionAndAnswer:(QuestionAndAnswer *)qaa{
    return [LicenseImageCell getCellHeightForQuestionAndAnswer:qaa];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.cellHeight = 260;
        
        // Initialization code
        self.retakeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 200, 100)];
        [self.retakeButton setTitle:@"Retake Image" forState:UIControlStateNormal];
        [self.retakeButton setBackgroundColor:[UIColor greenColor]];
        [self.requiredLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.takeButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        
        int takeImageButtonWidth = 200;
        int takeImageButtonHeight = 100;
        int takeImageButtonLeftPad = (self.frame.size.width - 200) / 2;
        int takeImageButtonTopPad = (260 - takeImageButtonHeight) / 2;
        self.takeButton = [[UIButton alloc] initWithFrame:CGRectMake(takeImageButtonLeftPad, takeImageButtonTopPad, takeImageButtonWidth, takeImageButtonHeight)];
        [self.takeButton setTitle:@"Take Image" forState:UIControlStateNormal];
        [self.takeButton setBackgroundColor:[UIColor greenColor]];
        [self.takeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.takeButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        
        
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
    [self.loadingProgress removeFromSuperview];
    self.qaa.answer.imageDetails.image = [[UIImage alloc] initWithData:data];
    [[self.delegate tableView] reloadData];
    [self putImageInView];
}

-(void)putImageInView{
//    NSLog(@"Putting image in view, length: %@", self.qaa.answer.imageDetails.image);
    int width = self.qaa.answer.imageDetails.image.size.width / SCALE_IMAGE_BY;
    int height = self.qaa.answer.imageDetails.image.size.height / SCALE_IMAGE_BY;
    int leftPad = 0;
    if(width < height){
        // need to center the image
        leftPad = (self.contentView.frame.size.width - width)/2;
    }
//    NSLog(@"%ld %ld", (long)width, (long) height);
    if(self.imageV != nil){
        [self.imageV removeFromSuperview];
        self.imageV = nil;
    }
    self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(leftPad, 15, width, height)];// w:153  h:16 204
    [self.imageV setImage:[self.qaa.answer.imageDetails.image copy]];
    [self.contentView addSubview:self.imageV];
}

-(void)setUpViewNeedToTakeImage{
    if (self.imageV != nil) {
//        NSLog(@"removed from view");
        [self.imageV removeFromSuperview];
        self.imageV = nil;
    }
//    self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];// w:153  h:16 204
    [self.contentView addSubview:self.takeButton];
}

-(BOOL)hasImage{
    return (self.qaa.answer.imageDetails.image != nil);
}

-(BOOL)needsToTakeImage{
//    NSLog(@"%@", [ImageDetails dictionaryFromImageDetails:self.qaa.answer.imageDetails]);
    if (self.qaa.answer.imageDetails == nil || (self.qaa.answer.imageDetails.image == nil && self.qaa.answer.imageDetails.bucketId == 0 && self.qaa.answer.imageDetails.answerId == 0))
        return YES;
    return NO;
//    return (self.qaa.answer.imageDetails == nil || self.qaa.answer.imageDetails.image == nil);
}

-(CGRect)requiredLabelRectWithPreviousTopPadding:(CGFloat)previousTopPadding{
    CGSize requiredSize = CGSizeMake(300, 9999);
    CGRect requiredRect = [licRequiredLabelText boundingRectWithSize:requiredSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0f]} context:nil];
//    NSLog(@"thing: %d, %f, %d, %f", licRequiredLabelLeftPad, licLabelTopPad + previousTopPadding + 10, licRequiredLabelWidth, requiredRect.size.height);
    return CGRectMake(licRequiredLabelLeftPad, licLabelTopPad + previousTopPadding + 10, licRequiredLabelWidth, requiredRect.size.height);
}

-(CGRect)questionLabelRect{
    CGSize labelSize = CGSizeMake(licLabelMaxWidth, 9999);
    CGRect textRect = [self.qaa.question.questionTextEnglish boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont  systemFontOfSize:15.0f]} context:nil];
    CGRect labelRect = CGRectMake(licLabelLeftPad, licLabelTopPad, textRect.size.width, textRect.size.height);
    return labelRect;
}

-(void)setUpWithQuestionAndAnswer:(QuestionAndAnswer *)qaa tableDelegate:(NewLicenseListViewController *)tableDelegate{
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
    
    if ([self needsToTakeImage]){
//        NSLog(@"needs to take image");
        [self setUpViewNeedToTakeImage];
    }else {
//        NSLog(@"doesnt need to take image");
        if ([self hasImage]) // put image on screen
            [self putImageInView];
        else{
            [self setupLoadingProgress];
            [[SBDaoV1 sharedManager] getImageForAnswerId:self.qaa.answer.imageDetails.answerId forDelegate:self];// go get image
        }
    }
}

-(void)setupLoadingProgress{
    int progressViewWidth = self.frame.size.width;
    int progressViewHeight = 10;
    int progressViewX = 0;
    int progressViewY = self.frame.size.height - progressViewHeight;
    self.loadingProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(progressViewX, progressViewY, progressViewWidth, progressViewHeight)];
    [self.loadingProgress setProgress:0.0f];
    [self addSubview:self.loadingProgress];
}

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
//    NSLog(@"then image: %@", progress);
    // TODO add image progress here
    self.imageConnection = connection;
    [self.loadingProgress setProgress:progress.fractionCompleted];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SBImageUploadingProgress" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:progress,@"progress", nil]];
}

-(void)imageFinished:(FinishedPhoto *)finishedPhoto{
//    NSLog(@"image finished, filename: %@", finishedPhoto.filename);
    [self.loadingProgress removeFromSuperview];
    self.qaa.answer.imageDetails.photoName = finishedPhoto.filename;
    self.qaa.answer.imageDetails.bucketId = finishedPhoto.bucketId;
    [self.delegate performSelector:@selector(didFinishUploadingImageData)];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SBImageFinishedUploading" object:self];
//    NSLog(@"imageDetails: %@", [QuestionAndAnswer dictionaryFromQuestionAndAnswer:self.qaa]);
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
//            self.imagePickerController = [[UIImagePickerController alloc] init];
//            [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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
    self.qaa.answer.imageDetails.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageSavingStarted = true;
    NSData *data = [UIImageJPEGRepresentation(self.qaa.answer.imageDetails.image, ImageCompression) base64EncodedDataWithOptions:NSDataBase64Encoding76CharacterLineLength];
    [[SBDaoV1 sharedManager] putImage:data forStateId:44 forDelegate:self];// hard coded for utah
    [self putImageInView];
    [self setupLoadingProgress];
    [[self.delegate tableView] reloadData];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == CantGetLocationTag) {
        if ([self.delegate respondsToSelector:@selector(setTabBarSelectedIndex:)]) {
            [self.delegate performSelector:@selector(setTabBarSelectedIndex:) withObject:0];
        }
    }
}

// find out what the cell recieves when it it getting dismissed
-(void)dismissView{
//    NSLog(@"closing modal");
    if ([self.delegate respondsToSelector:@selector(dismissAuthModal:)]) {
        if (self.imageConnection != nil) {
            [self.imageConnection cancel];
        }
        
        [self.delegate performSelector:@selector(dismissAuthModal:) withObject:self];
    }
//    else
//        NSLog(@"Delegate cannot dismiss details modal");
}

#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
//    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
//    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
