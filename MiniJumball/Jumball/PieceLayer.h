//
//  PieceLayer.h
//  Jumball
//
//  Created by Li Xu on 10/12/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "JumballEngine.h"
#import <QuartzCore/QuartzCore.h>

@interface PieceLayer : CALayer
{
    JumballCorner corner;
    CGColorRef color;
    CGFloat radius;
}

@property(nonatomic, readonly)JumballCorner corner;

-(id)initWithCorner:(JumballCorner)corner color:(CGColorRef)color radius:(CGFloat)radius;

@end
