//
//  ViewController.m
//  PaintIcons
//
//  Created by Li Xu on 10/9/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	JBGSetUpJumballGraphics();
    
    // 114 x 114 大棋盘
    [self computeAttributesWithWidth:114 segmentCount:12];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(114, 114), YES, 1.0f);
    CGContextRef ctx =  UIGraphicsGetCurrentContext();
    
    [self drawBkg:ctx];
    [self fillCornerAndCenter:ctx];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    NSData* imgData = UIImagePNGRepresentation(image);
    NSString* pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/114x114.png"];
    [imgData writeToFile:pngPath atomically:YES];
    
    UIGraphicsEndImageContext();
    
    // 57 x 57 大棋盘
    [self computeAttributesWithWidth:57 segmentCount:12];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(57, 57), YES, 1.0f);
    ctx =  UIGraphicsGetCurrentContext();
    
    [self drawBkg:ctx];
    [self fillCornerAndCenter:ctx];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    imgData = UIImagePNGRepresentation(image);
    pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/57x57.png"];
    [imgData writeToFile:pngPath atomically:YES];
    
    // 1024 x 1024 大棋盘
    [self computeAttributesWithWidth:1024 segmentCount:12];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), YES, 1.0f);
    ctx =  UIGraphicsGetCurrentContext();
    
    [self drawBkg:ctx];
    [self fillCornerAndCenter:ctx];
    [self drawLines:ctx width_blue_4:16 width_blue_2:8 width_blue_1:4];
    [self drawBlueCells:ctx strokeWidth:3];
    
    // 画六个点
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef white = [UIColor whiteColor].CGColor;
    CGColorRef colors1[12] = {white, kJBGRed, white, kJBGGreen, white, kJBGPink, white, kJBGGold, white, kJBGPurple, white, kJBGYellow};
    CGPoint points[6] = {point_A, point_B, point_C, point_D, point_E, point_F};
    for (int i = 0; i < 6; ++i)
    {
        CFArrayRef colors = CFArrayCreate(NULL, (const void**)&colors1[2 * i + 1], 2, NULL);
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
        JBGFillGradientCircle(ctx, points[i], pieceRadius_ * 0.1, points[i], pieceRadius_ * 0.8f, gradient, kJBGDarkBlue);
        CGGradientRelease(gradient);
    }
    CGColorSpaceRelease(colorSpace);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    imgData = UIImagePNGRepresentation(image);
    pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/1024x1024.png"];
    [imgData writeToFile:pngPath atomically:YES];
    
    UIGraphicsEndImageContext();
}

- (void) drawBkg:(CGContextRef)ctx
{
    // 线性梯度填充
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGFloat height = width_;
    CGPoint start = CGPointMake(0, 0);
    CGPoint end = CGPointMake(0, height);
    
    const CGColorRef blues[] = {kJBGLightBlue, kJBGBlue, kJBGDarkBlue};
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)blues, sizeof(blues) / sizeof(blues[0]), NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
    
    CGContextDrawLinearGradient(ctx, gradient, start, end, options);
    
    CFRelease(colors);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void) fillCornerAndCenter:(CGContextRef)ctx
{
    // 先画中心梯度圆
    CGFloat r_2 = smallSegmentLength_ * segmentCount_ / 3;
    const CGColorRef blues[] = {kJBGDarkBlue, kJBGBlue, kJBGLightBlue};
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)blues, sizeof(blues) / sizeof(blues[0]), NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
    JBGFillGradientCircle(ctx, point_O, 0.1 , point_O, r_2, gradient, NULL);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CFRelease(colors);
    
    // 填充6个小三角形
    JBGFillTriangle(ctx, point_A, point_a, point_f, kJBGDarkRed);
    JBGFillTriangle(ctx, point_B, point_b, point_a, kJBGDarkGreen);
    JBGFillTriangle(ctx, point_C, point_c, point_b, kJBGDarkPink);
    JBGFillTriangle(ctx, point_D, point_d, point_c, kJBGDarkGold);
    JBGFillTriangle(ctx, point_E, point_e, point_d, kJBGDarkPurple);
    JBGFillTriangle(ctx, point_F, point_f, point_e, kJBGDarkYellow);
}

- (void) drawLines:(CGContextRef)ctx width_blue_4:(CGFloat)w4 width_blue_2:(CGFloat)w2 width_blue_1:(CGFloat)w1
{
    // 绘制棋盘网格线
    
    CGContextSaveGState(ctx);
    
    // 裁切出六角星
    CGContextBeginPath(ctx);
    CGPoint points[12] = {point_A, point_a, point_B, point_b, point_C, point_c, point_D, point_d, point_E, point_e, point_F, point_f};
    CGContextAddLines(ctx, points, sizeof(points) / sizeof(points[0]));
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 决定线条数量
    int segmentCount_3 = segmentCount_ / 3;
    
    // 黑色斜线
    CGPoint start = CGPointMake(point_D.x - smallSegmentLength_ * segmentCount_3, point_D.y);
    CGPoint end = CGPointMake(point_A.x - smallSegmentLength_ * segmentCount_3 * 3, point_A.y);
    
    for (int i = 0 ; i < segmentCount_3 * 4; ++i) {
        
        CGPathMoveToPoint(path, NULL, start.x, start.y);
        CGPathAddLineToPoint(path, NULL, end.x, end.y);
        start.x += smallSegmentLength_;
        end.x += smallSegmentLength_;
    }
    
    // 反斜线
    start = CGPointMake(point_D.x - smallSegmentLength_ * segmentCount_3 * 3, point_D.y);
    end = CGPointMake(point_A.x - smallSegmentLength_ * segmentCount_3, point_A.y);
    
    for (int i = 0 ; i <  segmentCount_3 * 4; ++i) {
        
        CGContextMoveToPoint(ctx, start.x, start.y);
        CGContextAddLineToPoint(ctx, end.x, end.y);
        start.x += smallSegmentLength_;
        end.x += smallSegmentLength_;
    }
    
    // 黑色横线
    float delta_y = smallSegmentLength_ * sqrtf(3.0f) * 0.5;
    start = CGPointMake(point_E.x, point_D.y + delta_y);
    end = CGPointMake(point_C.x, point_D.y + delta_y);
    
    for (int i = 0 ; i <  segmentCount_3 * 4; ++i) {
        
        CGContextMoveToPoint(ctx, start.x, start.y);
        CGContextAddLineToPoint(ctx, end.x, end.y);
        start.y += delta_y;
        end.y += delta_y;
    }
    
    JBGStrokePathByLines(ctx, path, kJBGDarkBlue, 2, NULL, 0.0f, NULL, 0.0f);
    
    CGPathRelease(path);
    
    // 恢复裁切
    CGContextRestoreGState(ctx);
    
    // 描三重线
    path = CGPathCreateMutable();
    CGPoint points_ACE[3] = {point_A, point_C, point_E};
    CGPathAddLines(path, NULL, points_ACE, sizeof(points_ACE)/sizeof(points_ACE[0]));
    CGPathCloseSubpath(path);
    
    CGPoint points_BDF[3] = {point_B, point_D, point_F};
    CGPathAddLines(path, NULL, points_BDF, sizeof(points_BDF)/sizeof(points_BDF[0]));
    CGPathCloseSubpath(path);
    
    JBGStrokePathByLines(ctx, path, kJBGDarkBlue, w4, kJBGBlue, w2, kJBGLightBlue, w1);
    CGPathRelease(path);
}

- (void) drawBlueCells:(CGContextRef)ctx strokeWidth:(CGFloat)w1
{
    CGColorRef whitle = [UIColor whiteColor].CGColor;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 棋子浅蓝阴影中心
    // 78/255.0, 215/255.0, 244/255.0, 1.0f,
    CGFloat lightBlueComponents[4] = {78/255.0f, 215/255.0f, 244/255.0f, 1.0f};
    CGColorRef lightBlue = CGColorCreate(colorSpace, lightBlueComponents);
    const CGColorRef blues[] = {lightBlue, whitle};
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)blues, sizeof(blues) / sizeof(blues[0]), NULL);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);

    // B D F 顶点对应小三角形内的 cells
    CGContextSetLineWidth(ctx, w1);
    int segmentCount_3 = segmentCount_ / 3;
    CGFloat sqrt_3 = sqrtf(3.0f);
    CGPoint start_points[3];
    start_points[0] = point_D;
    start_points[1] = CGPointMake(point_F.x + smallSegmentLength_ * (segmentCount_3 - 1) / 2, point_F.y - smallSegmentLength_ * (segmentCount_3 - 1) / 2 * sqrt_3);
    start_points[2] = CGPointMake(point_B.x - smallSegmentLength_ * (segmentCount_3 - 1) / 2, point_B.y - smallSegmentLength_ * (segmentCount_3 - 1) / 2 * sqrt_3);
    for (int i = 0; i < 3; ++i) {
        
        CGPoint start_point = start_points[i];
        for (int j = 0; j < segmentCount_ / 3; ++j) {
            
            CGPoint point = CGPointMake(start_point.x - smallSegmentLength_ * 0.5f * j,
                                        start_point.y + smallSegmentLength_ * 0.5f * sqrt_3 * j);
            for (int k = 0; k < j + 1; ++k) {
                CGPoint child_point = CGPointMake(point.x + smallSegmentLength_ * k, point.y);
                JBGFillGradientCircle(ctx, child_point, pieceRadius_ * 0.1, child_point, pieceRadius_ * 0.8f, gradient, kJBGDarkBlue);
            }
        }
    }
    
    // 三角形(∆ option + j)
    // ∆ ACE 内的 cells
    for (int i = 0; i < segmentCount_ + 1; ++i) {
        
        CGPoint point = CGPointMake(point_A.x - smallSegmentLength_ * 0.5f * i,
                                    point_A.y - smallSegmentLength_ * 0.5f * sqrt_3 * i);
        for (int j = 0; j < i + 1; ++j) {
            
            CGPoint child_point = CGPointMake(point.x + smallSegmentLength_ * j, point.y);
            JBGFillGradientCircle(ctx, child_point, pieceRadius_ * 0.1, child_point, pieceRadius_ * 0.8f, gradient, kJBGDarkBlue);
        }
    }
    
    CGGradientRelease(gradient);
    CFRelease(colors);
    
    CGColorSpaceRelease(colorSpace);
}

-(void)computeAttributesWithWidth:(int)width segmentCount:(int)segmentCount
{
    segmentCount_ = segmentCount;
    width_ = width;
    smallSegmentLength_ = width / (segmentCount + 3) + 0.6;
    pieceRadius_ = smallSegmentLength_ * 0.33f;
    homeRadius_ = smallSegmentLength_ * 0.5f;
    
    float sqrt_3 = sqrtf(3.0f);
    float triangleSideLength = smallSegmentLength_ * segmentCount / 3;
    
    // 中心
    point_O = CGPointMake(width / 2, width / 2);
    
    // 外圈6个点
    
    point_A = CGPointMake(point_O.x,
                          point_O.y + triangleSideLength * sqrt_3);
    
    point_B = CGPointMake(point_O.x + triangleSideLength * 1.5f,
                          point_O.y + triangleSideLength * 0.5f * sqrt_3);
    
    point_C = CGPointMake(point_O.x + triangleSideLength * 1.5f,
                          point_O.y - triangleSideLength * 0.5f * sqrt_3);
    
    point_D = CGPointMake(point_O.x,
                          point_O.y - triangleSideLength * sqrt_3);
    
    point_E = CGPointMake(point_O.x - triangleSideLength * 1.5f,
                          point_O.y - triangleSideLength * 0.5f * sqrt_3);
    
    point_F = CGPointMake(point_O.x - triangleSideLength * 1.5f,
                          point_O.y + triangleSideLength * 0.5f * sqrt_3);
    
    // 内圈6个点
    
    point_a = CGPointMake(point_O.x + triangleSideLength * 0.5f,
                          point_O.y + triangleSideLength * 0.5f * sqrt_3);
    
    point_b = CGPointMake(point_O.x + triangleSideLength,
                          point_O.y);
    
    point_c = CGPointMake(point_O.x + triangleSideLength * 0.5f,
                          point_O.y - triangleSideLength * 0.5f * sqrt_3);
    
    point_d = CGPointMake(point_O.x - triangleSideLength * 0.5f,
                          point_O.y - triangleSideLength * 0.5f * sqrt_3);
    
    point_e = CGPointMake(point_O.x - triangleSideLength,
                          point_O.y);
    
    point_f = CGPointMake(point_O.x - triangleSideLength * 0.5f,
                          point_O.y + triangleSideLength * 0.5f * sqrt_3);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
