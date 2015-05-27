//
//  JumballGraphics.h
//  Jumball
//
//  Created by Li Xu on 10/8/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#ifndef Jumball_JumballGraphics_h
#define Jumball_JumballGraphics_h

#include <CoreGraphics/CoreGraphics.h>
#include <QuartzCore/QuartzCore.h>

/**
 * 关于颜色的选区：深色用来绘制棋盘，浅色配合白色绘制棋子，蓝色用来绘制背景和线条
 */

extern CGColorRef kJBGWhite;
extern CGColorRef kJBGLightBlue;
extern CGColorRef kJBGBlue;
extern CGColorRef kJBGDarkBlue;
extern CGColorRef kJBGDarkRed;
extern CGColorRef kJBGRed;
extern CGColorRef kJBGDarkGold;
extern CGColorRef kJBGGold;
extern CGColorRef kJBGDarkGreen;
extern CGColorRef kJBGGreen;
extern CGColorRef kJBGDarkPurple;
extern CGColorRef kJBGPurple;
extern CGColorRef kJBGDarkPink;
extern CGColorRef kJBGPink;
extern CGColorRef kJBGDarkYellow;
extern CGColorRef kJBGYellow;

// 建立和系统(Create一些绘图需要的全局变量)
/**
 * 如果图形系统已经建立，则直接返回
 * 图形系统需要用到的全局对象将会一直存在于内存中，直到程序结束
 * 并没有与SetUp对应的TearDown函数
 */
void JBGSetUpJumballGraphics();

// 填充三角形
void JBGFillTriangle(CGContextRef ctx, CGPoint point_a, CGPoint point_b, CGPoint point_c, CGColorRef color);

// 描三重线
void JBGStrokePathByLines(CGContextRef ctx, CGPathRef path, CGColorRef color_1, CGFloat width_1, CGColorRef color_2, CGFloat width_2, CGColorRef color_3, CGFloat width_3);

// 填充梯度圆并描边
void JBGFillGradientCircle(CGContextRef ctx, CGPoint center_1, CGFloat r_1, CGPoint center_2, CGFloat r_2, CGGradientRef fill_gradient, CGColorRef stroke_color);

#endif
