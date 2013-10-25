//
//  LoadingModalViewController.m
//  SalesmanBuddyiOS
//
//  Created by Taylor McCord on 10/24/13.
//  Copyright (c) 2013 McCord Inc. All rights reserved.
//

#import "LoadingModalViewController.h"

@interface LoadingModalViewController ()

@end

@implementation LoadingModalViewController

- (id)initWithTitle:(NSString *)title message:(NSString *)message{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = title;
        self.message = message;
    }
    return self;
}

-(void)dismiss{
    NSLog(@"recieved dismiss");
    [self removeFromParentViewController];
}

-(NSInteger)makeLabelWithText:(NSString *)text x:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height topPad:(NSInteger)topPad view:(UIView *)view backgroundColor:(UIColor *)color alignToCenter:(BOOL)alignToCenter{
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

- (void)viewDidLoad{
    [super viewDidLoad];
    NSInteger modalWidth = [self view].frame.size.height * .5f;
    NSInteger modalHeight = [self view].frame.size.width * .5f;
    [self.view setBackgroundColor:[UIColor clearColor]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(([self view].frame.size.width - modalWidth) * .5f, ([self view].frame.size.width - modalHeight) * .5f, modalWidth, modalHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
    NSInteger yValue = [self makeLabelWithText:self.title x:0 y:0 width:modalWidth height:modalHeight topPad:0 view:view backgroundColor:[UIColor clearColor] alignToCenter:YES];
    yValue = [self makeLabelWithText:self.message x:0 y:yValue width:modalWidth height:modalHeight topPad:10 view:view backgroundColor:[UIColor clearColor] alignToCenter:YES];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
