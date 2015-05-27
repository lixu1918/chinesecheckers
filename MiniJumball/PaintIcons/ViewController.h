//
//  ViewController.h
//  PaintIcons
//
//  Created by Li Xu on 10/9/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JumballGraphics.h"

@interface ViewController : UIViewController
{
    // 线段EC包含小线段的数目，大棋盘 4*3=12 小棋盘 3*3=9
    int segmentCount_;
    
    float width_;
    // 小线段长
    float smallSegmentLength_;
    // 棋子半径
    float pieceRadius_;
    // 老巢半径
    float homeRadius_;
    // 关键点坐标
    CGPoint point_A, point_B, point_C, point_D, point_E, point_F;
    CGPoint point_a, point_b, point_c, point_d, point_e, point_f;
    CGPoint point_O;
}

// 计算小线段长，关键点坐标等
-(void)computeAttributesWithWidth:(int)width segmentCount:(int)segmentCount;

// 分四个步骤画图
- (void) drawBkg:(CGContextRef)ctx;
- (void) fillCornerAndCenter:(CGContextRef)ctx;
- (void) drawLines:(CGContextRef)ctx width_blue_4:(CGFloat)w4 width_blue_2:(CGFloat)w2 width_blue_1:(CGFloat)w1;
- (void) drawBlueCells:(CGContextRef)ctx strokeWidth:(CGFloat)w1;

@end
