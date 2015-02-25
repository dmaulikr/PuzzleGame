//
//  GameProperties.h
//  HW_SlicedImages
//
//  Created by Gena on 22.02.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GamePoint;

@interface GameProperties : NSObject

@property (nonatomic, assign) CGFloat rowsCount;
@property (nonatomic, assign) CGFloat columnsCount;
@property (nonatomic, assign) CGFloat elemWidth;
@property (nonatomic, assign) CGFloat elemHieght;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic) GamePoint *emptyPoint;

- (GameProperties *)initPropertiesWithImageNamed: (NSString *)imageName;

@end
