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
#import "GamePoint.h"

@interface Game () {
    GameProperties *properties;
    GamePoint *startPoint;
    NSArray *copyOfImagesArray;
    int stepsCount;
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

- (void)startHidingImages
{
    UIImageView *startImage = self.imagesArray[startPoint.y][startPoint.x];
    startImage.alpha = 0;
    GamePoint *currentPoint = startPoint;
    for (int k = stepsCount; k > 0; k--) {
        [UIView animateWithDuration:10.0 delay:0.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
            NSArray *points = [self getAvailiablePointsFromCurrent:currentPoint];
            GamePoint *selectedPoint = points[arc4random_uniform((int)points.count)];
            [self swapFirstImage:self.imagesArray[selectedPoint.y][selectedPoint.x] WithSecond:self.imagesArray[currentPoint.y][currentPoint.x]];
        } completion:^(BOOL finished) {
            
        }];
//        NSArray *points = [self getAvailiablePointsFromCurrent:currentPoint];
//        GamePoint *selectedPoint = points[arc4random_uniform((int)points.count)];
//        [self swapFirstImage:self.imagesArray[selectedPoint.y][selectedPoint.x] WithSecond:self.imagesArray[currentPoint.y][currentPoint.x]];
    }
}

- (void)swapFirstImage: (UIImageView *)first WithSecond: (UIImageView *)second
{
    UIImageView *temp = [UIImageView new];
    temp.image = first.image;
    first.image = second.image;
    second.image = temp.image;
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

#pragma mark Game settings

- (void)setupGameWithImageNamed: (NSString *)name
{
    properties = [[GameProperties alloc] initPropertiesWithImageNamed:name];
    [self generateStartPosition];
    stepsCount = arc4random_uniform(properties.rowsCount * properties.columnsCount - 1);
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
