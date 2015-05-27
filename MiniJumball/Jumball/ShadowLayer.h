//
//  ShadowLayer.h
//  Jumball
//
//  Created by Li Xu on 10/12/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

///////////////////////////////////////////////////////////////////////////
// 三角形(实际上是梯形)阴影
/*
 .            A-D
 .           /   \
 .          /     \
 .         B-------C
 */
@interface TriangleShadowLayer : CALayer {
    CGFloat radius;
    // 关键点坐标
    CGPoint point_A, point_B, point_C, point_D;
}

- (id) initWithRadius:(CGFloat)radius;

@end

///////////////////////////////////////////////////////////////////////////
// 六边形阴影
@interface HexagonShadowLayer : CALayer {
    CGFloat radius;
    // 关键点坐标
    CGPoint point_a, point_b, point_c, point_d, point_e, point_f;
}

- (id) initWithRadius:(CGFloat)radius;

@end

