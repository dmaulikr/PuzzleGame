//
//  DetailViewController.m
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import "DetailViewController.h"
#import "Game.h"
#import "GameProperties.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface DetailViewController () <UIScrollViewDelegate> {
    GameProperties *properties;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthOfView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)startGamePressed:(UIButton *)sender;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    properties = [[Game sharedInstance] getGameProperties];
    
    [self resizeMainView];
    [self addArrayWithEmptyImagesOnMainView];
    [[Game sharedInstance] completeArrayWithImages];
    [self.startButton setUserInteractionEnabled: YES];
    
    self.scrollView.delegate = self;
    float minZoom = MIN(self.view.bounds.size.width / self.widthOfView.constant,
                        self.view.bounds.size.height / self.heightOfView.constant);
    self.scrollView.minimumZoomScale = (minZoom < 1) ? minZoom : 1;
    self.scrollView.maximumZoomScale = 6.0;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    
    self.mainView.userInteractionEnabled = YES;
    [self.mainView addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)resizeMainView
{
    self.widthOfView.constant = properties.elemWidth * properties.columnsCount;
    self.heightOfView.constant = properties.elemHieght * properties.rowsCount;
    [self.mainView setNeedsUpdateConstraints];
}

- (void)addArrayWithEmptyImagesOnMainView
{
    [[Game sharedInstance] createArrayWithEmptyImages];
    for (NSArray *elementArray in [Game sharedInstance].imagesArray) {
        for (UIImageView *imageView in elementArray) {
            [self.mainView addSubview:imageView];
        }
    }
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mainView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    float imageWidth = self.mainView.frame.size.width;
    float imageHeight = self.mainView.frame.size.height;
    
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    
    // center image if it is smaller than screen
    float hPadding = (viewWidth - imageWidth) / 2.0;
    if (hPadding < 0) hPadding = 0;
    
    float vPadding = (viewHeight - imageHeight) / 2.0;
    if (vPadding < 0) vPadding = 0;
    
    self.constraintLeft.constant = hPadding;
    self.constraintRight.constant = hPadding;
    self.constraintTop.constant = vPadding;
    self.constraintBottom.constant = vPadding;
    
    // Makes zoom out animation smooth and starting from the right point not from (0, 0)
    [self.view layoutIfNeeded];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint touchLocation = [tapGestureRecognizer locationInView:self.mainView];
    GamePoint *touchInGamePoint = [[Game sharedInstance] getGamePointFromCGPoint:touchLocation];
    properties = [[Game sharedInstance] getGameProperties];
    
    if (touchInGamePoint.y == properties.emptyPoint.y) {
        if (touchInGamePoint.x < properties.emptyPoint.x) {
            [[Game sharedInstance] moveImagesToRightFromX:touchInGamePoint.x];
        }
        if (touchInGamePoint.x > properties.emptyPoint.x) {
            [[Game sharedInstance] moveImagesToLeftFromX:touchInGamePoint.x];
        }
    }
    if (touchInGamePoint.x == properties.emptyPoint.x) {
        if (touchInGamePoint.y < properties.emptyPoint.y) {
            [[Game sharedInstance] moveImagesToBottomFromY:touchInGamePoint.y];
        }
        if (touchInGamePoint.y > properties.emptyPoint.y) {
            [[Game sharedInstance] moveImagesToTopFromY:touchInGamePoint.y];
        }
    }
    if ([[Game sharedInstance] checkForGameCompleated]) {
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [[Game sharedInstance] showHiddenImage];
        } completion:^(BOOL finished) {
            [[Game sharedInstance] setupBordersForAllImagesEnabled:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.mainView animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"Compleated";
                [hud hide:YES afterDelay:1.0];
                [self.startButton setUserInteractionEnabled:YES];
            });
            
        }];
    }
}

- (IBAction)startGamePressed:(UIButton *)sender {
    [[Game sharedInstance] setupBordersForAllImagesEnabled:YES];
    [[Game sharedInstance] startHidingImages];
    [self.startButton setUserInteractionEnabled: NO];
}
@end