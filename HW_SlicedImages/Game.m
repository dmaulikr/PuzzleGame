//
//  Game.m
//  HW_SlicedImages
//
//  Created by Gena on 22.02.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Game.h"
#import "NetManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface Game () {
    GameProperties *properties;
    GamePoint *startPoint;
    NSArray *copyOfImagesArray;
    int stepsCount;
    NSMutableArray *generatedPathOfPoints;
}

typedef enum int16_t {
    StartBorderLeft,
    StartBorderRight,
    StartBorderTop,
    StartBorderBottom
}StartBorder;

@end

@implementation Game

+ (instancetype)sharedInstance
{
    static id _game = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _game = [[self alloc] init];
    });
    return _game;
}

- (void)getTitlesOfImages: (void(^)(NSArray *))completion
{
    [[NetManager sharedInstance] getTitles:^(NSArray *arr, NSError *error) {
        if (!error) {
            self.imagesArray = arr;
            NSMutableArray *titles = [NSMutableArray new];
            for (NSDictionary *dict in self.imagesArray) {
                [titles addObject:dict[@"folder_name"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(titles);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }];
}

- (GameProperties *)getGameProperties
{
    return properties;
}

- (void)createArrayWithEmptyImages
{
    NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i < properties.rowsCount; i++) {
        NSMutableArray *elementsInRow = [NSMutableArray new];
        for (int j = 0; j < properties.columnsCount; j++) {
            CGRect frame = CGRectMake(j * properties.elemWidth, i * properties.elemHieght, properties.elemWidth, properties.elemHieght);
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
            [elementsInRow addObject:imgView];
        }
        [arr addObject:elementsInRow];
    }
    self.imagesArray = [arr copy];
}

- (void)completeArrayWithImages
{
    for (int i = 0; i < properties.rowsCount; i++) {
        for (int j = 0; j < properties.columnsCount; j++) {
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://dl.dropboxusercontent.com/u/55523423/NetExample/%@/%d_%d.png", properties.imageName, i, j]];
            [self.imagesArray[i][j] sd_setImageWithURL:imageURL];
        }
    }
    copyOfImagesArray = self.imagesArray;
}

- (void)generateStartPosition
{
    StartBorder startBorder = (StartBorder)arc4random_uniform(3);
    int positionInBorder;
    switch (startBorder) {
        case StartBorderLeft: {
            positionInBorder = arc4random_uniform(properties.rowsCount - 1);
            startPoint = [[GamePoint alloc] initWithX:0 Y:positionInBorder];
            break;
        }
        case StartBorderRight: {
            positionInBorder = arc4random_uniform(properties.rowsCount - 1);
            startPoint = [[GamePoint alloc] initWithX:properties.columnsCount - 1 Y:positionInBorder];
            break;
        }
        case StartBorderTop: {
            positionInBorder = arc4random_uniform(properties.columnsCount - 1);
            startPoint = [[GamePoint alloc] initWithX:positionInBorder Y:0];
            break;
        }
        case StartBorderBottom: {
            positionInBorder = arc4random_uniform(properties.columnsCount - 1);
            startPoint = [[GamePoint alloc] initWithX:positionInBorder Y:properties.rowsCount - 1];
            break;
        }
    }
}

- (void)animateImages
{
    if (generatedPathOfPoints.count == 1) return;
    [UIView animateWithDuration:0.1 animations:^{
        GamePoint *previousPoint = [generatedPathOfPoints firstObject];
        [generatedPathOfPoints removeObjectAtIndex:0];
        GamePoint *currentPoint = [generatedPathOfPoints firstObject];
        UIImageView *previousImage = self.imagesArray[previousPoint.y][previousPoint.x];
        UIImageView *currentImage = self.imagesArray[currentPoint.y][currentPoint.x];
        [self swapSomeImage:previousImage AnotherImageWithAnimation:currentImage];
    } completion:^(BOOL finished) {
        [self animateImages];
    }];
}

- (void)startHidingImages
{
    generatedPathOfPoints = [NSMutableArray new];
    [generatedPathOfPoints addObject:startPoint];
    [UIView animateWithDuration:0.1 animations:^{
        UIImageView *startImage = self.imagesArray[startPoint.y][startPoint.x];
        startImage.alpha = 0;
    } completion:^(BOOL finished) {
        GamePoint *currentPoint = startPoint;
        GamePoint *previousPoint = nil;
        GamePoint *selectedPoint;
        for (int k = stepsCount - 1; k > 0; k--) {
            NSArray *points = [self getAvailiablePointsFromCurrent:currentPoint];
            selectedPoint = points[arc4random_uniform((int)points.count)];
            if (previousPoint) {
                while (selectedPoint.x == previousPoint.x && selectedPoint.y == previousPoint.y) {
                    selectedPoint = points[arc4random_uniform((int)points.count)];
                }
            }
            [generatedPathOfPoints addObject:selectedPoint];
            previousPoint = currentPoint;
            currentPoint = selectedPoint;
        }
        [self animateImages];
    }];
}

- (void)swapSomeImage: (UIImageView *)someImage AnotherImageWithAnimation: (UIImageView *)anotherImage
{
    
    UIImageView *temp = [UIImageView new];
    temp.image = someImage.image;
    someImage.image = anotherImage.image;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [someImage.layer addAnimation:transition forKey:nil];
    
    anotherImage.image = temp.image;
    
    
    [anotherImage.layer addAnimation:transition forKey:nil];
    someImage.alpha = 1;
    anotherImage.alpha = 0;
}

- (NSArray *)getAvailiablePointsFromCurrent: (GamePoint *)currentPoint
{
    NSMutableArray *points = [NSMutableArray new];
    if (currentPoint.x - 1 >= 0) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x - 1 Y:currentPoint.y]];
    if (currentPoint.y - 1 >= 0) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x Y:currentPoint.y - 1]];
    if (currentPoint.x + 1 < properties.columnsCount) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x + 1 Y:currentPoint.y]];
    if (currentPoint.y + 1 < properties.rowsCount) [points addObject:[[GamePoint alloc] initWithX:currentPoint.x Y:currentPoint.y + 1]];
    return points;
}

- (GamePoint *)getGamePointFromCGPoint: (CGPoint)point
{
    GamePoint *gamePoint = [GamePoint new];
    gamePoint.y = (int)(point.y / properties.elemHieght);
    gamePoint.x = (int)(point.x / properties.elemWidth);
    return gamePoint;
}

#pragma mark Game settings

- (void)setupGameWithImageNamed: (NSString *)name
{
    properties = [[GameProperties alloc] initPropertiesWithImageNamed:name];
    [self generateStartPosition];
    stepsCount = arc4random_uniform(properties.rowsCount * properties.columnsCount - 1);
    while (stepsCount < 4) {
        stepsCount = arc4random_uniform(properties.rowsCount * properties.columnsCount - 1);
    }
    NSLog(@"steps: %d", stepsCount);
}

- (void)configureBordersForImageView: (UIImageView *)imageView
{
    UIColor *borderColor = [UIColor blackColor];
    [imageView.layer setBorderColor:borderColor.CGColor];
    [imageView.layer setBorderWidth:1.0];
}

- (void)setupBordersForAllImages
{
    for (int i = 0; i < properties.rowsCount; i++) {
        for (int j = 0; j < properties.columnsCount; j++) {
            [self configureBordersForImageView:self.imagesArray[i][j]];
        }
    }
}


@end
