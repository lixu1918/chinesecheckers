//
//  JumballGraphics.c
//  Jumball
//
//  Created by Li Xu on 10/8/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#include "JumballGraphics.h"
#include <stdio.h>

// 白色
CGColorRef kJBGWhite;

// 浅蓝 204 224 244
CGColorRef kJBGLightBlue;

// 蓝 29 156 215
CGColorRef kJBGBlue;

// 深蓝 0 50 126
CGColorRef kJBGDarkBlue;

// 深红 Firebrick3 205 38 38
CGColorRef kJBGDarkRed;

// 红 Firebrick2 238 44 44
CGColorRef kJBGRed;

// 深金 DarkGoldenrod3 205 149 12
CGColorRef kJBGDarkGold;

// 金 DarkGoldenrod2	238 173 14 (原来选的是255 215 0)
CGColorRef kJBGGold;

// 深绿 SpringGreen3 0 205 102
CGColorRef kJBGDarkGreen;

// 绿 SpringGreen2 0 238 118
CGColorRef kJBGGreen;

// 深紫 Purple3 125 38 205
CGColorRef kJBGDarkPurple;

// 紫 Purple2 145 44 238
CGColorRef kJBGPurple;

// 深粉红 Magenta3	205 0 205
CGColorRef kJBGDarkPink;

// 粉红 Magenta2	238 0 238
CGColorRef kJBGPink;

// 深黄 Yellow3	205 205 0
CGColorRef kJBGDarkYellow;

// 黄 Yellow2	238 238 0
CGColorRef kJBGYellow;

void JBGSetUpJumballGraphics()
{
    CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
    
    // 白色
    CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    kJBGWhite = CGColorCreate(color_space, white);
    
    // 浅蓝 204 224 244
    CGFloat light_blue[4] = {204/255.0f, 224/255.0f, 244/255.0f, 1.0f};
    kJBGLightBlue = CGColorCreate(color_space, light_blue);
    
    // 蓝 29 156 215
    CGFloat blue[4] = {29/255.0f, 156/255.0f, 215/255.0f, 1.0f};
    kJBGBlue = CGColorCreate(color_space, blue);
    
    // 深蓝 0 50 126
    CGFloat dark_blue[4] = {0, 50/255.0f, 126/255.0f, 1.0f};
    kJBGDarkBlue = CGColorCreate(color_space, dark_blue);
    
    // 深红 Firebrick3 205 38 38
    CGFloat dark_red[4] = {205/255.0f, 38/255.0f, 38/255.0f, 1.0f};
    kJBGDarkRed = CGColorCreate(color_space, dark_red);
    
    // 红 Firebrick2 238 44 44
    CGFloat red[4] = {238/255.0f, 44/255.0f, 44/255.0f, 1.0f};
    kJBGRed = CGColorCreate(color_space, red);
    
    // 深金 DarkGoldenrod3 205 149 12
    CGFloat dark_gold[4] = {205/255.0f, 149/255.0f, 12/255.0f, 1.0f};
    kJBGDarkGold = CGColorCreate(color_space, dark_gold);
    
    // 金 DarkGoldenrod2	238 173 14 (原来选的是255 215 0)
    CGFloat gold[4] = {238/255.0f, 173.0f/255.0f, 14/255.0f, 1.0f};
    kJBGGold = CGColorCreate(color_space, gold);
    
    // 深绿 SpringGreen3 0 205 102
    CGFloat dark_green[4] = {0, 205/255.0f, 102/255.0f, 1.0f};
    kJBGDarkGreen = CGColorCreate(color_space, dark_green);
    
    // 绿 SpringGreen2 0 238 118
    CGFloat green[4] = {0, 238/255.0f, 118/255.0f, 1.0f};
    kJBGGreen = CGColorCreate(color_space, green);
    
    // 深紫  Purple3 125 38 205
    CGFloat dark_purple[4] = {125/255.0f, 38/255.0f, 205/255.0f, 1.0f};
    kJBGDarkPurple = CGColorCreate(color_space, dark_purple);
    
    // 紫 Purple2 145 44 238
    CGFloat purple[4] = {145/255.0f, 44/255.0f, 238/255.0f, 1.0f};
    kJBGPurple = CGColorCreate(color_space, purple);
    
    // 深粉红 Magenta3	205 0 205
    CGFloat dark_pink[4] = {205/255.0f, 0/255.0f, 205/255.0f, 1.0f};
    kJBGDarkPink = CGColorCreate(color_space, dark_pink);
    
    // 粉红 Magenta2	238 0 238
    CGFloat pink[4] = {238/255.0f, 0/255.0f, 238/255.0f, 1.0f};
    kJBGPink = CGColorCreate(color_space, pink);
    
    // 深黄 Yellow3	205 205 0
    CGFloat dark_yellow[4] = {205, 205/255.0f, 0/255.0f, 1.0f};
    kJBGDarkYellow = CGColorCreate(color_space, dark_yellow);
    
    // 黄 Yellow2	238 238 0
    CGFloat yellow[4] = {238, 238/255.0f, 0/255.0f, 1.0f};
    kJBGYellow = CGColorCreate(color_space, yellow);
    
    CGColorSpaceRelease(color_space);
}

void JBGFillTriangle(CGContextRef ctx, CGPoint point_a, CGPoint point_b, CGPoint point_c, CGColorRef color)
{
    CGContextBeginPath(ctx);
    CGPoint points[] = {point_a, point_b, point_c};
    CGContextAddLines(ctx, points, sizeof(points) / sizeof(points[0]));
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, color);
    CGContextFillPath(ctx);
}

void JBGStrokePathByLines(CGContextRef ctx, CGPathRef path, CGColorRef color_1, CGFloat width_1, CGColorRef color_2, CGFloat width_2, CGColorRef color_3, CGFloat width_3)
{
    if (width_1 > 0.0f)
    {
        CGContextSetLineWidth(ctx, width_1);
        CGContextAddPath(ctx, path);
        CGContextSetStrokeColorWithColor(ctx, color_1);
        CGContextStrokePath(ctx);
    }

    if (width_2 > 0.0f)
    {
        CGContextAddPath(ctx, path);
        CGContextSetStrokeColorWithColor(ctx, color_2);
        CGContextSetLineWidth(ctx, width_2);
        CGContextStrokePath(ctx);
    }
    
    if (width_3 > 0.0f)
    {
        CGContextAddPath(ctx, path);
        CGContextSetStrokeColorWithColor(ctx, color_3);
        CGContextSetLineWidth(ctx, width_3);
        CGContextStrokePath(ctx);
    }
}

void JBGFillGradientCircle(CGContextRef ctx, CGPoint center_1, CGFloat r_1, CGPoint center_2, CGFloat r_2, CGGradientRef fill_gradient, CGColorRef stroke_color)
{
    if (fill_gradient)
    {
        CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation;
        CGContextDrawRadialGradient(ctx, fill_gradient, center_1, r_1, center_2, r_2, options);
    }
    
    if (stroke_color)
    {
        CGContextSetStrokeColorWithColor(ctx, stroke_color);
        CGContextAddArc(ctx, center_2.x, center_2.y, r_2, 0, M_PI * 2, false);
        CGContextStrokePath(ctx);
    }
}