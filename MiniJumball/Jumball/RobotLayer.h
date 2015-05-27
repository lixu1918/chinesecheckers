//
//  JumballRobotLayer.h
//  MiniJumball
//
//  Created by Li Xu on 9/28/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface JumballRobotLayer : CALayer
{
    CGColorRef color;
    CGFloat radius, r1, r2;
    CGPoint point_A, point_B, point_C, point_D, point_E, point_F;
    CGPoint point_O;
    CGPoint  eye_1, eye_2;
}

-(id)initWithColor:(CGColorRef)aColor;

@end
