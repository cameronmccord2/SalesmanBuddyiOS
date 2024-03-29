//
//  LoadingModalViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "LoadingModalViewController.h"

@interface LoadingModalViewController ()
//SBImageUploadingProgress
@end

@implementation LoadingModalViewController

- (id)initWithTitle:(NSString *)title message:(NSString *)message useUploadProgress:(BOOL)useUploadProgress{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = title;
        self.message = message;
        self.useUploadProgress = useUploadProgress;
        self.progress = nil;// trash?
    }
    return self;
}

//- (id)initWithTitle:(NSString *)title message:(NSString *)message useUploadProgress:(BOOL)useUploadProgress numberToWaitOn:(NSInteger)numberToWaitOn notificationName:(NSString *)notificationName progressName:(NSString *)progressNotificationName{
//    self = [self initWithTitle:title message:message useUploadProgress:useUploadProgress];
//    if (self) {
//        self.numberToWaitOn = numberToWaitOn;
//        self.notificationName = notificationName;
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(finishedAnother:)
//                                                     name:notificationName object:nil];
//        self.progressNotificationName = progressNotificationName;
//    }
//    return self;
//}



-(void)dismiss{
    NSLog(@"recieved dismiss, LoadingModalViewController");
    [self removeFromParentViewController];
}

-(NSInteger)makeLabelWithText:(NSString *)text x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height topPad:(NSInteger)topPad view:(UIView *)view backgroundColor:(UIColor *)color alignToCenter:(BOOL)alignToCenter{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(x, y + topPad, width, height)];
    [view addSubview:title];
    [title setBackgroundColor:color];
    [title setText:text];
    title.numberOfLines = 0;
    if (alignToCenter) {
        [title setTextAlignment:NSTextAlignmentCenter];
        //        [title alignCenterXWithView:view predicate:nil];
    }
    self.lastLabel = title;
    return y + height + topPad;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSInteger modalWidth = [self view].frame.size.height * .5f;
    NSInteger modalHeight = [self view].frame.size.width * .5f;
    [self.view setBackgroundColor:[UIColor clearColor]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(([self view].frame.size.width - modalWidth) * .5f, ([self view].frame.size.width - modalHeight) * .5f, modalWidth, modalHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
    NSInteger yValue = [self makeLabelWithText:self.title x:0 y:0 width:modalWidth height:20 topPad:0 view:view backgroundColor:[UIColor clearColor] alignToCenter:YES];
    yValue = [self makeLabelWithText:self.message x:0 y:yValue width:modalWidth height:20 topPad:10 view:view backgroundColor:[UIColor clearColor] alignToCenter:YES];
    if (self.useUploadProgress) {
        yValue = [self makeLabelWithText:@"0%" x:0 y:yValue width:modalWidth height:30 topPad:10 view:view backgroundColor:[UIColor blueColor] alignToCenter:YES];
    }
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)connectionUploadProgress:(NSNumber *)progress total:(NSNumber *)total{
    if (self.progress == nil) {
        self.progress = [NSProgress progressWithTotalUnitCount:total.longValue];
    }
    self.progress.completedUnitCount = progress.longValue;
    [self.lastLabel setText:self.progress.localizedDescription];
}


#pragma mark - MTCAuthManagerViewControllerDelegateProtocal

-(void)showAuthModal:(UIViewController *)viewController{
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)dismissAuthModal:(UIViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
