//
//  JumballRobotLayer.m
//  MiniJumball
//
//  Created by Li Xu on 9/28/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#import "RobotLayer.h"

@implementation JumballRobotLayer

-(id)initWithColor:(CGColorRef)aColor
{
    self = [super init];
    if (self) {
        color = aColor;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

-(void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    radius = bounds.size.width / 2;
    r1 = M_PI / 12;
    r2 = M_PI / 3;
    
    point_O = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);

    point_A.x = point_O.x + radius * cosf(r1);
    point_A.y = point_O.y - radius * sinf(r1);
    
    point_B.x = point_O.x + radius * cosf(r2);
    point_B.y = point_O.y - radius * sinf(r2);
    
    point_C.x = point_O.x - radius * cosf(r2);
    point_C.y = point_O.y - radius * sinf(r2);
    
    point_D.x = point_O.x - radius * cosf(r1);
    point_D.y = point_O.y - radius * sinf(r1);
    
    point_E.x = point_O.x;
    point_E.y = point_O.y - radius;
    
    point_F.x = self.bounds.size.width;
    point_F.y = point_E.y - radius / 12;
    
    eye_1.x = point_O.x + radius * cosf(r2) * 0.7f;
    eye_1.y = point_O.y - radius * sinf(r2) * 0.7f;
    
    eye_2.x = point_O.x - radius * cosf(r2) * 0.7f;
    eye_2.y = point_O.y - radius * sinf(r2) * 0.7f;
}

-(void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, color);
    CGContextBeginPath(ctx);
    // 因为y向下增长（可以把UIView系统里的顺时针当逆时针,角度取负）
    CGContextAddArc(ctx, point_O.x, point_O.y, radius, -r1, r1 - M_PI, YES);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);

    CGContextBeginPath(ctx);
    CGPoint points[3] = {point_B, point_E, point_F};
    CGContextAddLines(ctx, points, 3);
    CGContextClosePath(ctx); 
    CGContextFillPath(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, eye_1.x, eye_1.y, radius / 6, 0, 2 * M_PI, NO);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, eye_2.x, eye_2.y, radius / 6, 0, 2 * M_PI, NO);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

@end
