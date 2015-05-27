//
//  JumballView.h
//  Jumball
//
//  Created by Li Xu on 10/11/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JumballEngine.h"
#import "CursorLayer.h"
#import "PieceLayer.h"
#import "ShadowLayer.h"
#import "RobotLayer.h"

@protocol JumballViewDelegate;

@interface JumballView : UIView
{
    id<JumballViewDelegate> delegate;
    
    // 棋子CALayer
    NSMutableDictionary* pieces;
    
    // sublayers
    // 对于小棋盘：脚印最多 30个，因为最多30颗棋子，就算某棋子在跳过每个棋子时都留下一个脚印，也不超过30个
    //对于大棋盘：共184个空位，因此脚印最大可能数也等于最大棋子数60
    // 但事实上，因为在简单寻路算法的搜索深度已经被限制在30以内，所以，脚印数就定为30吧。
    // 如果确实需要可以再增加
    CursorLayer* footPrints[30];
    
    // 脚印游标，留下新脚印时，用于播放从上一个脚印到新脚印的动画
    // 棋子游标下方
    CursorLayer* footPrintCursor;
    
    // 棋子游标（走子动画用）, 箭头光标下方
    PieceLayer* pieceCursors[kJBECornerMax];
    
    // 箭头游标(选择棋子和目的地用），最上层
    CursorLayer* arrowCursors[kJBECornerMax];
    
    // 机器人
    JumballRobotLayer* robots[kJBECornerMax];
    CGPoint robotHomes[kJBECornerMax];
    
    // 三角形阴影
    TriangleShadowLayer* triangleShadows[kJBECornerMax];
    
    // 中心六边形阴影
    HexagonShadowLayer* centerShadow;
    
    // 棋盘的宽，并不完全等同于屏幕宽，需要做一些调整
    float boardWidth_;
    // 线段EC包含小线段的数目，大棋盘 4*3=12 小棋盘 3*3=9
    int segmentCount_;
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
    // 棋盘六个角的填充颜色
    CGColorRef cornerFillColors[kJBECornerMax];
    // 棋盘六个cell的填充颜色
    CGColorRef cornerCellColors[kJBECornerMax];
    // 棋盘六个方位棋子图片(代码生成)
    UIImage* cornerPieceImages[kJBECornerMax];
}

@property(nonatomic,assign)id<JumballViewDelegate> delegate;

@property(nonatomic, assign)CGPoint point_O;
@property(nonatomic, readonly)CGPoint point_A, point_B, point_C, point_D, point_E, point_F;
@property(nonatomic, readonly)CGPoint point_a, point_b, point_c, point_d, point_e, point_f;

// 棋子操作
-(void)addPieceOfCorner:(JumballCorner)corner pieceId:(int)pieceId;
-(void)removePieceOfKey:(int)pieceId;
-(void)hidePieceOfKey:(int)pieceId hide:(BOOL)hide;
-(void)movePieceOfKey:(int)pieceId toRow:(int)row column:(int)column;

// 走子动画
-(void)movePieceCursor:(JumballCorner)corner along:(NSArray*)array;

// 脚印操作
-(void) removeFootPrints;
-(CALayer*) addFootPrintRow:(int)row column:(int)column;
- (void) rotateLayer:(CALayer*)layer toDirection: (JumballDirection)direction;
- (void) rotateLayer:(CALayer*)layer toAngle:(CGFloat)angle;
- (void) moveFootPrintCursorFromRow:(int)from_row column:(int)from_column toRow:(int)to_row toColumn:(int)to_column forCorner:(JumballCorner)corner;

// 箭头游标
-(void)addArrowCursor:(JumballCorner)corner toRow:(int)row column:(int)column;
-(void)removeArrowCursor:(JumballCorner)corner;
-(BOOL)moveArrowCursor:(JumballCorner)corner direction:(JumballDirection)direction;
-(void)rotateArrowCursor:(JumballCorner)corner toDirection:(JumballDirection)direction;
-(BOOL)coordinateOfArrowCurser:(JumballCorner)corner row:(int*)row column:(int*)column;

// 机器人操作
-(void) hideRobot:(JumballCorner)corner hide:(BOOL)hide;
-(void) navigateRobot:(JumballCorner)corner navigate:(BOOL)navigate;

// 显示或隐藏阴影
-(void)hideTriangleShadow:(JumballCorner)corner hide:(BOOL)hide;
-(void)hideCenterShadow:(BOOL)hide;

// 建立脚印，游标层
- (void) setupLayers;

// 棋盘外观设置(viewcontroller 调用以下3个方法，设置棋盘参数供 drawRect 使用)

// 设置棋盘的宽，以及线段EC包含小线段的数目
/**
 在调用此方法之前需要调用 setPoint_O 确定棋盘的位置
 */
-(void)setBoardWidth:(CGFloat)width segmentCount:(int)segmentCount;
// 设置棋盘六个方位三角形的填充颜色
-(void)setFillColorSouth:(CGColorRef)southColor southEast:(CGColorRef)southEastColor northEast:(CGColorRef)northEastColor north:(CGColorRef)northColor northWest:(CGColorRef)northWestColor southWest:(CGColorRef)southWestColor;
// 设置棋盘六个 homeCell 的颜色
-(void)setHomeCellColorSouth:(CGColorRef)southColor southEast:(CGColorRef)southEastColor northEast:(CGColorRef)northEastColor north:(CGColorRef)northColor northWest:(CGColorRef)northWestColor southWest:(CGColorRef)southWestColor;

@end

@protocol JumballViewDelegate <NSObject>

-(void)pieceCursorStopMoving:(JumballCorner)corner;

@end
