//
//  Game.h
//  HW_SlicedImages
//
//  Created by Gena on 22.02.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameProperties.h"

@interface Game : NSObject

@property (nonatomic, strong) NSArray *imagesArray;
//@property (nonatomic, strong) NSArray *titlesArray;

+ (instancetype)sharedInstance;

- (void)getTitlesOfImages: (void(^)(NSArray *))completion;
- (void)setupGameWithImageNamed: (NSString *)name;
- (GameProperties *)getGameProperties;
- (void)createArrayWithEmptyImages;
- (void)completeArrayWithImages;
- (void)setupBordersForAllImages;
- (void)startHidingImages;

@end
