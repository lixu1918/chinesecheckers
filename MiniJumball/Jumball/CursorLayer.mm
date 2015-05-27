//
//  CursorLayer.m
//  Jumball
//
//  Created by Li Xu on 10/12/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "CursorLayer.h"

@implementation CursorLayer

@synthesize row, column;

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    // 计算关键点坐标
    CGFloat sqrt_3 = sqrtf(3.0f);
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    point_A = CGPointMake(center.x, center.y - radius);
    point_B = CGPointMake(center.x - radius * 0.5 * sqrt_3, center.y - radius * 0.25);
    point_C = CGPointMake(center.x - radius * 0.25 * sqrt_3, center.y - radius * 0.25);
    point_D = CGPointMake(center.x - radius * 0.25 * sqrt_3, center.y + radius * 0.5);
    point_E = CGPointMake(center.x + radius * 0.25 * sqrt_3, center.y + radius * 0.5);
    point_F = CGPointMake(center.x + radius * 0.25 * sqrt_3, center.y - radius * 0.25);
    point_G = CGPointMake(center.x + radius * 0.5 * sqrt_3, center.y - radius * 0.25);
}

- (id) initWithCorner:(JumballCorner)aCorner color:(CGColorRef)aColor radius:(CGFloat)aRadius
{
    self = [super init];
    if (self) {
        corner = aCorner;
        color = aColor;
        radius = aRadius;
        self.contentsScale = [[UIScreen mainScreen] scale];
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{    
    CGPoint points[7] = {point_A, point_B, point_C, point_D, point_E, point_F, point_G};
    CGContextBeginPath(ctx);
    CGContextAddLines(ctx, points, sizeof(points) / sizeof(points[0]));
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, color);
    CGContextFillPath(ctx);
      
    if (corner != kJBECornerMax)
    {   
        CGContextBeginPath(ctx);
        CGContextAddLines(ctx, points, sizeof(points) / sizeof(points[0]));
        CGContextClosePath(ctx);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetStrokeColorWithColor(ctx, kJBGDarkBlue);
        CGContextStrokePath(ctx);
    }
}

@end

