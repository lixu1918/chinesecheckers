//
//  ShadowLayer.m
//  Jumball
//
//  Created by Li Xu on 10/12/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "ShadowLayer.h"
#include "JumballGraphics.h"

///////////////////////////////////////////////////////////////////////////
// 三角形阴影
@implementation TriangleShadowLayer

-(id)initWithRadius:(CGFloat)aRadius
{
    self = [super init];
    if (self) {
        
        radius = aRadius;
        CGFloat width = radius * sqrtf(3.2f);
        CGFloat height = radius + radius;
        self.bounds = CGRectMake(0, 0, width, height);
        
        CGFloat width_2 = width * 0.5f;
        CGFloat radius_2 = radius * 0.5f;
        CGFloat sqrt_3 = sqrtf(3.0f);
        point_A = CGPointMake(width_2 - 5.5, 11);
        point_B = CGPointMake(width_2 - radius_2 * sqrt_3, radius_2 * 3);
        point_C = CGPointMake(width_2 + radius_2 * sqrt_3, radius_2 * 3);
        point_D = CGPointMake(width_2 + 5.5, 11);
    }
    return self;
}

-(void)drawInContext:(CGContextRef)ctx
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint points[4] = {point_A, point_B, point_C, point_D};
    CGPathAddLines(path, NULL, points, sizeof(points)/sizeof(points[0]));
    CGPathCloseSubpath(path);
    
    // 阴影
    UIColor* shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    CGContextSetFillColorWithColor(ctx, shadowColor.CGColor);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    // 描线
    CGContextSetLineWidth(ctx, 4);
    CGContextSetStrokeColorWithColor(ctx, kJBGDarkBlue);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetStrokeColorWithColor(ctx, kJBGBlue);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, kJBGLightBlue);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGPathRelease(path);
}

@end

///////////////////////////////////////////////////////////////////////////
// 六边形阴影
@implementation HexagonShadowLayer

-(id)initWithRadius:(CGFloat)aRadius
{
    self = [super init];
    if (self) {
        radius = aRadius;
        CGPoint center = CGPointMake(radius + 10, radius);
        self.bounds = CGRectMake(0, 0, radius + radius + 20, radius + radius);
        
        CGFloat radius_2 = radius * 0.5f;
        CGFloat sqrt_3 = sqrtf(3.0f);
        point_a = CGPointMake(center.x + radius_2, center.y + radius_2 * sqrt_3);
        point_b = CGPointMake(center.x + radius, center.y);
        point_c = CGPointMake(center.x + radius_2, center.y - radius_2 * sqrt_3);
        point_d = CGPointMake(center.x - radius_2, center.y - radius_2 * sqrt_3);
        point_e = CGPointMake(center.x - radius, center.y);
        point_f = CGPointMake(center.x - radius_2, center.y + radius_2 * sqrt_3);
    }
    return self;
}

-(void)drawInContext:(CGContextRef)ctx
{
    CGContextBeginPath(ctx);
    
    CGPoint points[6]= {point_a, point_b, point_c, point_d, point_e, point_f};
    CGContextAddLines(ctx, points, 6);
    
    CGContextClosePath(ctx);
    
    UIColor* shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    CGContextSetFillColorWithColor(ctx, shadowColor.CGColor);
    CGContextFillPath(ctx);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint points_ACE[6] = {point_a, point_b, point_c, point_d, point_e, point_f};
    CGPathAddLines(path, NULL, points_ACE, sizeof(points_ACE)/sizeof(points_ACE[0]));
    CGPathCloseSubpath(path);
    
    CGContextSetLineWidth(ctx, 4);
    CGContextSetStrokeColorWithColor(ctx, kJBGDarkBlue);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetStrokeColorWithColor(ctx, kJBGBlue);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, kJBGLightBlue);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGPathRelease(path);
}

@end 
