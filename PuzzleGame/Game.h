//
//  Game.h
//  PuzzleGame
//
//  Created by Гена on 27.02.15.
//  Copyright (c) 2015 fix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameProperties.h"
#import "GamePoint.h"

@interface Game : NSObject

@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, strong) NSArray *dataArray;

+ (instancetype)sharedInstance;

- (void)getTitlesOfImages: (void(^)(NSArray *))completion;
- (void)setupGameWithImageNamed: (NSString *)name;
- (GameProperties *)getGameProperties;
- (void)createArrayWithEmptyImages;
- (void)completeArrayWithImages;
- (void)setupBordersForAllImagesEnabled: (BOOL)enabled;
- (void)startHidingImages;
- (GamePoint *)getGamePointFromCGPoint: (CGPoint)point;

- (void)moveImagesToLeftFromX: (int)fromX;
- (void)moveImagesToRightFromX: (int)fromX;
- (void)moveImagesToTopFromY: (int)fromY;
- (void)moveImagesToBottomFromY: (int)fromY;

- (void)showHiddenImage;

- (BOOL)checkForGameCompleated;

@end
