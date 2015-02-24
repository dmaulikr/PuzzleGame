//
//  GamePoint.h
//  HW_SlicedImages
//
//  Created by Gena on 23.02.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GamePoint : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;

- (GamePoint *)initWithX: (int)x
                   Y: (int)y;

@end
