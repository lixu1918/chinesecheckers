//
//  MiniJumballStick.h
//  MiniJumball
//
//  Created by Li Xu on 9/22/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

/*************************************************************************
// 注意，同一个程序中，只允许存在一个 MiniJumballStick 实例
// 因为使用了全局变量，2个或以上个实例同时存在会打架
 */

/*
. 外接圆半径 radius
. 角 A B C D E F 分别对应当前 stick 摇向的方向
.               D---+-c-+---C
.              /      |      \
.             d       +       b
.            /\       |      / \
.           +    \    +    /    +
.          /        \ | /        \
.         E---+---+---O---+---+---B
.          \        / | \        /
.           +    /    +    \    +
.            \ /      |      \ /
.             e       +       a
.              \      |      /
.               F---+-f-+---A
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class LinesLayer;
@class StickLayer;

@protocol MiniJumballStickDelegate;

@interface MiniJumballStick : UIView
{    
@private
    id<MiniJumballStickDelegate> delegate;
    //LinesLayer *linesLayer;
    StickLayer *stickLayer;

    // for drag stickLayer
    CGPoint stickHome;
    CGFloat innerRadius;
    CGPoint touchLocation;
    BOOL dragging;
}

@property(nonatomic,assign)IBOutlet id<MiniJumballStickDelegate> delegate;

@end

@protocol MiniJumballStickDelegate <NSObject>

-(void)doubleTapOnCenterButton:(id)sender;
-(void)tapOnCenterButton:(id)sender;
// radius 表示stick与circle碰撞点与水平直径右端点所成圆心角的弧度，取值范围同atan2f[-π π]
-(void)stickHitCircle:(id)sender radius:(float)radius;

@end

@interface LinesLayer : CALayer
@end

@interface StickLayer : CALayer

-(void)goToPosition:(CGPoint)newPosition;

@end
