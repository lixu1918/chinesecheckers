//
//  MiniJumballStick.m
//  MiniJumball
//
//  Created by Li Xu on 9/22/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#import "MiniJumballStick.h"

const CGFloat kDragThreshold = 2.0f;
float distanceBetweenPoints(CGPoint a, CGPoint b);

@interface MiniJumballStick()

-(void)setupLayers;
-(void)setupGestureRecognizers;
//-(void)singleTap:(id)sender;
-(void)doubleTap:(id)sender;

@end

@implementation MiniJumballStick

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        innerRadius = self.bounds.size.width / 6;
        stickHome = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        //self.layer.contentscale = [UIScreen mainScreen].scale;
        [self setupLayers];
        [self setupGestureRecognizers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

        innerRadius = self.bounds.size.width / 6;
        stickHome = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
        [self setupLayers];
        [self setupGestureRecognizers];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchLocation = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint newLocation = [[touches anyObject] locationInView:self];
    CGFloat moveDistance = distanceBetweenPoints(newLocation, touchLocation);
        
    if (dragging) {
        
        CGFloat distanceToStick = distanceBetweenPoints(newLocation, stickHome);
        
        float delta_x = newLocation.x - stickHome.x;
        float delta_y = newLocation.y - stickHome.y;
        float r = atan2f(-delta_y, delta_x);
        
        BOOL hitCircle = NO;
        // 原来这个值是1.6 * innerRadius 改成 1.4 顺畅多了
        if (distanceToStick > 1.4 * innerRadius) {
            
            hitCircle = YES;
            distanceToStick = 1.4 * innerRadius;
        }

        float x = distanceToStick * cosf(r);
        float y = distanceToStick * sinf(r);
        
        [CATransaction begin];
        [CATransaction setDisableActions: YES];
        // 禁用隐式动画
        stickLayer.position = CGPointMake(stickHome.x + x, stickHome.y - y);
        [CATransaction commit];
        
        touchLocation = newLocation;
        
        if (hitCircle) {
            [delegate stickHitCircle:self radius:r];
        }
        
    } else {
        
        if (moveDistance > kDragThreshold) 
        {
            dragging = YES;
            touchLocation = newLocation;
        }
    }        
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!dragging) {
        CGPoint newLocation = [[touches anyObject] locationInView:self];
        CGFloat moveDistance = distanceBetweenPoints(newLocation, stickHome);
        
        if (moveDistance < innerRadius * 2) {
            [delegate tapOnCenterButton:self];
        }
    }
    dragging = NO;
    [stickLayer goToPosition:stickHome];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    dragging = NO;
    [stickLayer goToPosition:stickHome];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat r0 = -M_PI / 6;
    CGFloat delta_r = M_PI / 3;
    
    CGContextSetLineWidth(ctx, 2);
    for (int i = 0; i < 6; ++i) {
        
        r0 += delta_r;
        
        if (i % 2 == 0) {
            // 深蓝
            CGContextSetRGBStrokeColor(ctx, 0 / 255.0f,  50.0 / 255.0f, 126 / 255.0f, 1);
        } else {
            // 蓝
            CGContextSetRGBStrokeColor(ctx, 29 / 255.0f,  156 / 255.0f, 215 / 255.0f, 1);
        }
        
        CGContextAddArc(ctx, stickHome.x, stickHome.y, innerRadius * 2.5, r0, r0 + delta_r, NO);
        CGContextStrokePath(ctx);
    }
}

#pragma mark -  MiniJumballStick()

//-(void)singleTap:(UITapGestureRecognizer*)sender
//{
//    CGPoint point = [sender locationInView:self]; 
//    CGFloat distance = distanceBetweenPoints(point, stickHome);
//    
//    if (distance < innerRadius * 2)
//    {
//        [delegate tapOnCenterButton:self];
//    }
//}

-(void)doubleTap:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self]; 
    CGFloat distance = distanceBetweenPoints(point, stickHome);
    
    if (distance < innerRadius * 2)
    {
        [delegate doubleTapOnCenterButton:self];
    }
}

-(void)setupGestureRecognizers
{
    // 不使用 tap gestrure recognizer 检查 single tap 因为反应比较慢
//    UITapGestureRecognizer *singleTap =
//    [[[UITapGestureRecognizer alloc] initWithTarget:self
//                                             action:@selector(singleTap:)] autorelease];
//    singleTap.numberOfTapsRequired = 1;
//    singleTap.numberOfTouchesRequired = 1;
//    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap =
    [[[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(doubleTap:)] autorelease];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTap];
    //[singleTap requireGestureRecognizerToFail:doubleTap];
}

-(void)setupLayers
{
    self.layer.delegate = self;
    [self.layer setNeedsDisplay];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    // linesLayer
//    linesLayer = [LinesLayer layer];
//    linesLayer.contentsScale = scale;
//    linesLayer.frame = self.bounds;
//    linesLayer.needsDisplayOnBoundsChange = YES;
//    [linesLayer setNeedsDisplay];
//    [self.layer addSublayer:linesLayer];
    
    // stickLayer
    stickLayer = [StickLayer layer];
    stickLayer.contentsScale = scale;
    stickLayer.bounds = self.bounds;
    stickLayer.position = stickHome;
    stickLayer.needsDisplayOnBoundsChange = YES;
    [stickLayer setNeedsDisplay];
    [self.layer addSublayer:stickLayer];
}

@end

#pragma mark -
#pragma LinesLayer

@implementation LinesLayer

-(void)drawInContext:(CGContextRef)ctx
{
    //CGContextStrokeRect(ctx, CGRectMake(0, 0, 20, 20));
}

@end

@implementation StickLayer

-(void)goToPosition:(CGPoint)newPosition
{
    CGPoint oldPosition = self.position;
  
//    [CATransaction begin];
//    [CATransaction setDisableActions: YES];
//    // 禁用隐式动画
//    self.position = newPosition;
//    [CATransaction commit];
    
    float distanceFromDest = distanceBetweenPoints(oldPosition, newPosition);  
    float animationDuration = 0.1 + distanceFromDest * 0.001; 
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = [NSValue valueWithCGPoint:oldPosition];
	rotationAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
	rotationAnimation.duration = animationDuration;
    rotationAnimation.removedOnCompletion = YES;
    rotationAnimation.fillMode = kCAFillModeBoth;
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	[self addAnimation:rotationAnimation forKey:@"goNewPosition"];
    
    self.position = newPosition;
}

-(void)drawInContext:(CGContextRef)ctx
{
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGFloat stick_inner_radius = self.bounds.size.width / 6;
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    
    // 棋盘中间的蓝色梯度图
    static CGFloat colors[] =
    {
        // 浅蓝
        204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
        // 蓝
        29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
        // 深蓝
        0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
        // 蓝
        29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
        // 浅蓝
        204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
        // 蓝
        29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
        // 深蓝
        0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
    };
    
    CGGradientRef gradients[3];
    for (int i = 0; i < 3; ++i) {
        gradients[i] = CGGradientCreateWithColorComponents(rgb, &colors[i * 4 * 2], NULL, 3);
    }
    
    CGFloat stick_out_radius = stick_inner_radius * 2;

    CGContextDrawRadialGradient(ctx, gradients[0], center, stick_out_radius * 0.75f, center, stick_out_radius, options);
    CGContextDrawRadialGradient(ctx, gradients[1], center, stick_out_radius * 0.5f, center, stick_out_radius * 0.75f, options);
    CGContextDrawRadialGradient(ctx, gradients[2], center, 0, center, stick_out_radius * 0.5f, options);
    
    CGContextSetLineWidth(ctx, 1);    
    CGContextSetRGBStrokeColor(ctx, 0 / 255.0f,  50.0 / 255.0f, 126 / 255.0f, 1);
    CGContextAddArc(ctx, center.x, center.y, stick_out_radius, 0, M_PI * 2, NO);
    CGContextStrokePath(ctx);
    
    for (int i = 0; i < sizeof(gradients) / sizeof(gradients[0]); ++i) {
        CGGradientRelease(gradients[i]);
    }
    CGColorSpaceRelease(rgb);

}

@end

float distanceBetweenPoints(CGPoint a, CGPoint b) {
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}
