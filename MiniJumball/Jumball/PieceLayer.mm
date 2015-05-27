//
//  PieceLayer.m
//  Jumball
//
//  Created by Li Xu on 10/12/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "PieceLayer.h"
#include "JumballGraphics.h"

@implementation PieceLayer

@synthesize corner;

-(id)initWithCorner:(JumballCorner)aCorner color:(CGColorRef)aColor radius:(CGFloat)aRadius
{
    self = [super init];
    if (self) {
        corner = aCorner;
        color = aColor;
        radius = aRadius;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

-(void)drawInContext:(CGContextRef)ctx
{    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGPoint up = CGPointMake(center.x, center.y - radius * 0.7f/*0.618f - 0.5*/);
    
    const CGColorRef corlors[] = {[UIColor whiteColor].CGColor, color};
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)corlors, sizeof(corlors) / sizeof(corlors[0]), NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
    
    JBGFillGradientCircle(ctx, up, radius * 0.1f, center, radius, gradient, color);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CFRelease(colors);
}

@end
