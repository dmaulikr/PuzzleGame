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
}


#pragma mark Game settings

- (void)setupGameWithImageNamed: (NSString *)name
{
    properties = [[GameProperties alloc] initPropertiesWithImageNamed:name];
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
