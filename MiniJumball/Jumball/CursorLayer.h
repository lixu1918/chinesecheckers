//
//  CursorLayer.h
//  Jumball
//
//  Created by Li Xu on 10/12/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JumballGraphics.h"
#import "JumballEngine.h"

/**
 *    A
 *   /\
 *  /  \
 *B/_CF_\G
 *   ||
 *   ||
 *   DE
 */

@interface CursorLayer : CALayer {

@private
    JumballCorner corner;
    CGColorRef color;
    CGFloat radius;

    // 在棋盘中的坐标
    int row, column;
    // 关键点坐标
    CGPoint point_A, point_B, point_C, point_D, point_E, point_F, point_G;
}

@property(nonatomic, assign)int row, column;

- (id) initWithCorner:(JumballCorner)corner color:(CGColorRef)color radius:(CGFloat)radius;

@end  ;
