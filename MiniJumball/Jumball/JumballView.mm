//
//  JumballView.m
//  Jumball
//
//  Created by Li Xu on 10/11/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "JumballView.h"
#import "JumballGraphics.h"

@interface JumballView()

// 计算小线段长，关键点坐标等
-(void)computeAttributesWithWidth:(int)width segmentCount:(int)segmentCount;

// 分四个步骤画图
- (void) drawBkg:(CGContextRef)ctx;
- (void) fillCornerAndCenter:(CGContextRef)ctx;
- (void) drawLines:(CGContextRef)ctx width_blue_4:(CGFloat)w4 width_blue_2:(CGFloat)w2 width_blue_1:(CGFloat)w1;
- (void) drawBlueCells:(CGContextRef)ctx strokeWidth:(CGFloat)w1;

-(CGPoint)piecePositionOfRow:(int)row column:(int)column;

@end

@implementation JumballView

@synthesize delegate;
@synthesize point_O;
@synthesize point_A, point_B, point_C, point_D, point_E, point_F;
@synthesize point_a, point_b, point_c, point_d, point_e, point_f;

- (void) dealloc
{
    [pieces release];
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        [cornerPieceImages[i] release];
    }
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //[self setupLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self setupLayers];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawBkg:ctx];
    [self fillCornerAndCenter:ctx];
    [self drawLines:ctx width_blue_4:4 width_blue_2:2 width_blue_1:1];
    [self drawBlueCells:ctx strokeWidth:1];
    
    // 画六个点
    CGContextSetLineWidth(ctx, 2);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef white = [UIColor whiteColor].CGColor;
    CGColorRef colors1[12] = {cornerCellColors[0], white, cornerCellColors[1], white, cornerCellColors[2], white, cornerCellColors[3], white, cornerCellColors[4], white, cornerCellColors[5], white};
    CGPoint points[6] = {point_A, point_B, point_C, point_D, point_E, point_F};
    for (int i = 0; i < 6; ++i)
    {
        CFArrayRef colors = CFArrayCreate(NULL, (const void**)&colors1[2 * i], 2, NULL);
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
        JBGFillGradientCircle(ctx, points[i], pieceRadius_ * 0.1, points[i], pieceRadius_ * 0.8f, gradient, kJBGDarkBlue);
        CGGradientRelease(gradient);
    }
    CGColorSpaceRelease(colorSpace);
}

#pragma mark -
#pragma mark 棋子操作

-(void)addPieceOfCorner:(JumballCorner)corner pieceId:(int)pieceId
{
    if (pieces == nil)
    {
        pieces = [[NSMutableDictionary alloc] initWithCapacity:30];
    }
    NSNumber* pieceKey = [NSNumber numberWithInt:pieceId];
    CALayer* piece = [pieces objectForKey:pieceKey];
    if (piece == nil)
    {
        CALayer* newPiece = [[CALayer alloc] init];
        newPiece.bounds = CGRectMake(0, 0, pieceRadius_ * 2.3, pieceRadius_ * 2.3);
        if (cornerPieceImages[corner] == NULL)
        {
            CGPoint center = CGPointMake(pieceRadius_ * 1.15, pieceRadius_ * 1.15);
            CGPoint up = CGPointMake(center.x, center.y - pieceRadius_ * 0.2f/*0.618f - 0.5*/);
            
            const CGColorRef corlors[] = {[UIColor whiteColor].CGColor, cornerCellColors[corner]};
            CFArrayRef colors = CFArrayCreate(NULL, (const void**)corlors, sizeof(corlors) / sizeof(corlors[0]), NULL);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
            
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(pieceRadius_ * 2.3, pieceRadius_ * 2.3), NO,     [UIScreen mainScreen].scale);
            CGContextRef pieceContext =  UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(pieceContext, 1);
            
            JBGFillGradientCircle(pieceContext, up, pieceRadius_ * 1.15 * 0.1f, center, pieceRadius_ * 1.15 * 0.9f, gradient, cornerCellColors[corner]);
            
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            cornerPieceImages[corner] = [image retain];
            
            UIGraphicsEndImageContext();
            
            CGGradientRelease(gradient);
            CGColorSpaceRelease(colorSpace);
            CFRelease(colors);
        }

        newPiece.contents = (id)(cornerPieceImages[corner].CGImage);
        
        // 旋转相应角度
        CGFloat pi_3 = M_PI / 3;
        newPiece.transform = CATransform3DMakeRotation(- corner * pi_3, 0, 0, 1);
        newPiece.needsDisplayOnBoundsChange = YES;
        //[newPiece setNeedsDisplay];
        [self.layer insertSublayer:newPiece atIndex:0];
        [newPiece release];
        [pieces setObject:newPiece forKey:pieceKey];
    }
    piece.hidden = NO;
}

-(void)removePieceOfKey:(int)pieceId
{
    NSNumber* pieceKey = [NSNumber numberWithInt:pieceId];
    CALayer* piece = [pieces objectForKey:pieceKey];
    [piece removeFromSuperlayer];
}

-(void)hidePieceOfKey:(int)pieceId hide:(BOOL)hide
{
    NSNumber* pieceKey = [NSNumber numberWithInt:pieceId];
    CALayer* piece = [pieces objectForKey:pieceKey];
    piece.hidden = hide;
}

-(CGPoint)piecePositionOfRow:(int)row column:(int)column
{
    CGFloat x_offset = column * smallSegmentLength_ * 0.5f;
    CGFloat y_offset = - row * smallSegmentLength_ * 0.5f * sqrtf(3.0f);
    return CGPointMake(point_O.x + x_offset, point_O.y + y_offset);
}

-(void)movePieceOfKey:(int)pieceId toRow:(int)row column:(int)column
{
    NSNumber* pieceKey = [NSNumber numberWithInt:pieceId];
    CALayer* piece = [pieces objectForKey:pieceKey];
    piece.position = [self piecePositionOfRow:row column:column];
}

#pragma mark -
#pragma mark 走子动画

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    // 所有棋子游标
    for (int i = 0; i < kJBECornerMax; ++i) {
        
        PieceLayer* pieceCursor = pieceCursors[i];
        CAAnimation* naimation = [pieceCursor animationForKey:@"MovePieceCursor"];
        
        if (theAnimation == naimation) {
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            pieceCursor.hidden = YES;
            [CATransaction commit];
            
            [delegate pieceCursorStopMoving:pieceCursor.corner];
            
            return;
        }
    }
    
    if (theAnimation == [footPrintCursor animationForKey:@"MoveFootPrintCursor"])
    {
        // 脚印游标
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        footPrintCursor.hidden = YES;
        [CATransaction commit];
    }
    
}

-(void)movePieceCursor:(JumballCorner)corner along:(NSArray*)array
{
    PieceLayer* pieceCursor = pieceCursors[corner];
    if (pieceCursor == nil || array.count < 2) {
        return;
    }
    
    NSValue* destValue = [array lastObject];
    CGPoint pointDest = [destValue CGPointValue];
    CGPoint destPosition = [self piecePositionOfRow:(int)pointDest.x column:(int)pointDest.y];
    
    // 先把棋子游标设为可见，并移动到目的地
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    pieceCursor.hidden = NO;
    pieceCursor.position = destPosition;
    [CATransaction commit];
    
    // 设置起始点
    NSValue* pointValue = [array objectAtIndex:0];
    CGPoint pointFrom = [pointValue CGPointValue];
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPoint originalPosition = [self piecePositionOfRow:pointFrom.x column:pointFrom.y];
    CGPathMoveToPoint(thePath,NULL, originalPosition.x, originalPosition.y);
    
    NSMutableArray* timeingFunctions = [NSMutableArray array];
    CGFloat duration = 0.35f * (array.count - 1);
    for (int i = 0; i < array.count - 1; ++i) {
        
        NSValue* pointToValue = [array objectAtIndex:i + 1];
        CGPoint pointTo = [pointToValue CGPointValue];
        CGPoint toPosition = [self piecePositionOfRow:pointTo.x column:pointTo.y];
        CGPathAddLineToPoint(thePath, NULL,
                             toPosition.x,
                             toPosition.y);
        
        [timeingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    
    CAKeyframeAnimation * theAnimation;
    theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.path=thePath;
    theAnimation.duration= duration;
    theAnimation.timingFunctions = timeingFunctions;
    theAnimation.delegate = self;
    theAnimation.removedOnCompletion = NO;
    [pieceCursor addAnimation:theAnimation forKey:@"MovePieceCursor"];
    
    CFRelease(thePath);
}

#pragma mark -
#pragma mark 脚印操作

- (void) moveFootPrintCursorFromRow:(int)from_row column:(int)from_column toRow:(int)to_row toColumn:(int)to_column forCorner:(JumballCorner)corner
{
    JumballDirection direction = JBEDirectionByRowColumn(from_row, from_column, to_row, to_column);
    CGPoint fromPosition;
    CGPoint toPosition = [self piecePositionOfRow:to_row column:to_column];
    if (direction != kJBEDirectionMax)
    {
        fromPosition = [self piecePositionOfRow:from_row column:from_column];
    }
    else
    {
        CGFloat angle = corner * M_PI / 3 - M_PI_2;
        CGFloat delta_x, delta_y;
        delta_x = 1.5f * pieceRadius_ * cosf(angle);
        delta_y = 1.5f * pieceRadius_ * sinf(angle);
        fromPosition = CGPointMake(toPosition.x + delta_x, toPosition.y - delta_y);
    }
    
    // 播放脚印动画
    // 不计算脚印箭头方向, 需要用户自己计算并旋转
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    footPrintCursor.position = toPosition;
    footPrintCursor.hidden = NO;
    if (direction != kJBEDirectionMax) {
        [self rotateLayer:footPrintCursor toDirection:direction];
    } else {
        [self rotateLayer:footPrintCursor toAngle:- corner * M_PI / 3];
    }
    
    [CATransaction commit];
    
    // 制作一个回弹效果!
    // 设置起始点
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathMoveToPoint(thePath,NULL, fromPosition.x, fromPosition.y);
    
    
    CGPathAddLineToPoint(thePath, NULL, toPosition.x, toPosition.y);
    CGPathAddLineToPoint(thePath, NULL,
                         fromPosition.x + (toPosition.x - fromPosition.x) * 0.8f,
                         fromPosition.y + (toPosition.y - fromPosition.y) * 0.8f);
    CGPathAddLineToPoint(thePath, NULL, toPosition.x, toPosition.y);
    
    CAKeyframeAnimation * theAnimation;
    theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.path=thePath;
    theAnimation.duration= 0.4f;
    theAnimation.delegate = self;
    theAnimation.removedOnCompletion = NO;
    [footPrintCursor addAnimation:theAnimation forKey:@"MoveFootPrintCursor"];
    
    CFRelease(thePath);
}

-(void)removeFootPrints
{
    for (int i = 0; i < sizeof(footPrints)/sizeof(footPrints[0]); ++i) {
        CursorLayer* footprint = footPrints[i];
        footprint.hidden = YES;
    }
}

-(CALayer*)addFootPrintRow:(int)row column:(int)column
{
    // 如果在 row column 位置已经存在一个脚印，则直接设置可见
    // 实际上，在这种情况下，原来的脚印多数时候本身就是可见的
    for (int i = 0; i <  sizeof(footPrints)/sizeof(footPrints[0]); ++i) {
        
        CursorLayer* footprint = footPrints[i];
        if (footprint.hidden == YES)
        {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            footprint.position = [self piecePositionOfRow:row column:column];
            [CATransaction commit];
            
            footprint.hidden = NO;
            return footprint;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark 箭头游标操作

-(void)addArrowCursor:(JumballCorner)corner toRow:(int)row column:(int)column
{
    CursorLayer* cursor = arrowCursors[corner];
    if (cursor) {
        
        // 禁用默认动画
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        cursor.position = [self piecePositionOfRow:row column:column];
        [CATransaction commit];
        
        // 使用默认动画
        cursor.row = row;
        cursor.column = column;
        cursor.hidden = NO;
        
        // 计算旋转角度
        CGFloat pi_3 = M_PI / 3;
        cursor.transform = CATransform3DMakeRotation(- corner * pi_3, 0, 0, 1);
    }
}

-(void)removeArrowCursor:(JumballCorner)corner
{
    CursorLayer* cursor = arrowCursors[corner];
    if (cursor) {
        cursor.hidden = YES;
    }
}

-(void)rotateArrowCursor:(JumballCorner)corner toDirection:(JumballDirection)direction
{
    CursorLayer* cursor = arrowCursors[corner];
    if (cursor) {
        [self rotateLayer:cursor toDirection:direction];
    }
}

- (void) rotateLayer:(CALayer*)layer toAngle:(CGFloat)angle
{
    layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void) rotateLayer:(CALayer*)layer toDirection: (JumballDirection)direction;
{
    static CGFloat pi_6 = M_PI / 6;
    
    if (layer == nil) {
        return;
    }
    
    CGFloat angle = 0.0f;
    switch (direction) {
        case kJBEDirectionEast:
            angle = M_PI_2;
            break;
        case kJBEDirectionNorthEast:
            angle = pi_6;
            break;
        case kJBEDirectionNorthWest:
            angle = - pi_6;
            break;
        case kJBEDirectionWest:
            angle = - M_PI_2;
            break;
        case kJBEDirectionSouthWest:
            angle = pi_6 - M_PI;
            break;
        case kJBEDirectionSouthEast:
            angle = M_PI - pi_6;
            break;
            
        default:
            break;
    }
    layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

-(BOOL)moveArrowCursor:(JumballCorner)corner direction:(JumballDirection)direction
{
    
    CursorLayer *currentCursor = arrowCursors[corner];
    if (currentCursor == nil) {
        return NO;
    }
    
    int row = currentCursor.row;
    int column = currentCursor.column;
    switch (direction) {
        case kJBEDirectionEast:
            column += 2;
            break;
        case kJBEDirectionNorthEast:
            row += 1;
            column += 1;
            break;
        case kJBEDirectionNorthWest:
            row += 1;
            column -= 1;
            break;
        case kJBEDirectionWest:
            column -= 2;
            break;
        case kJBEDirectionSouthWest:
            row -= 1;
            column -= 1;
            break;
        case kJBEDirectionSouthEast:
            row -= 1;
            column += 1;
            break;
            
        default:
            break;
    }
    
    CGPoint newPosition = [self piecePositionOfRow:row column:column];
    
    if (CGRectContainsPoint(self.bounds, newPosition)) {
        
        currentCursor.position = newPosition;
        currentCursor.row = row;
        currentCursor.column = column;
        return YES;
    }
    return NO;
}

-(BOOL)coordinateOfArrowCurser:(JumballCorner)corner row:(int*)row column:(int*)column
{
    CursorLayer *currentCursor = arrowCursors[corner];
    if (currentCursor == nil) {
        return NO;
    }
    *row = currentCursor.row;
    *column = currentCursor.column;
    return YES;
}

#pragma mark -
#pragma mark 机器人操作

-(void) hideRobot:(JumballCorner)corner hide:(BOOL)hide
{
    robots[corner].hidden = hide;
}

-(void) navigateRobot:(JumballCorner)corner navigate:(BOOL)navigate
{
    JumballRobotLayer* robot = robots[corner];
    if (robot == NULL) {
        return;
    }
    
    if (navigate) {
        // 开始机器人巡航
        CGPoint points[8];
        
        switch (corner) {
            case kJBECornerSouth:
            {
                points[0] = CGPointMake(point_A.x,  point_A.y);
                points[1] = CGPointMake(point_a.x,  point_a.y);
                points[2] = CGPointMake(point_b.x,  point_b.y);
                points[3] = CGPointMake(point_c.x,  point_c.y);
                points[4] = CGPointMake(point_d.x,  point_d.y);
                points[5] = CGPointMake(point_e.x,  point_e.y);
                points[6] = CGPointMake(point_f.x,  point_f.y);
                points[7] = CGPointMake(point_A.x,  point_A.y);
            }
                break;
            case kJBECornerSouthEast:
            {
                points[0] = CGPointMake(point_B.x,  point_B.y);
                points[1] = CGPointMake(point_b.x,  point_b.y);
                points[2] = CGPointMake(point_c.x,  point_c.y);
                points[3] = CGPointMake(point_d.x,  point_d.y);
                points[4] = CGPointMake(point_e.x,  point_e.y);
                points[5] = CGPointMake(point_f.x,  point_f.y);
                points[6] = CGPointMake(point_a.x,  point_a.y);
                points[7] = CGPointMake(point_B.x,  point_B.y);
            }
                break;
            case kJBECornerNorthEast:
            {
                points[0] = CGPointMake(point_C.x,  point_C.y);
                points[1] = CGPointMake(point_c.x,  point_c.y);
                points[2] = CGPointMake(point_d.x,  point_d.y);
                points[3] = CGPointMake(point_e.x,  point_e.y);
                points[4] = CGPointMake(point_f.x,  point_f.y);
                points[5] = CGPointMake(point_a.x,  point_a.y);
                points[6] = CGPointMake(point_b.x,  point_b.y);
                points[7] = CGPointMake(point_C.x,  point_C.y);
            }
                break;
            case kJBECornerNorth:
            {
                points[0] = CGPointMake(point_D.x,  point_D.y);
                points[1] = CGPointMake(point_d.x,  point_d.y);
                points[2] = CGPointMake(point_e.x,  point_e.y);
                points[3] = CGPointMake(point_f.x,  point_f.y);
                points[4] = CGPointMake(point_a.x,  point_a.y);
                points[5] = CGPointMake(point_b.x,  point_b.y);
                points[6] = CGPointMake(point_c.x,  point_c.y);
                points[7] = CGPointMake(point_D.x,  point_D.y);
            }
                break;
            case kJBECornerNorthWest:
            {
                points[0] = CGPointMake(point_E.x,  point_E.y);
                points[1] = CGPointMake(point_e.x,  point_e.y);
                points[2] = CGPointMake(point_f.x,  point_f.y);
                points[3] = CGPointMake(point_a.x,  point_a.y);
                points[4] = CGPointMake(point_b.x,  point_b.y);
                points[5] = CGPointMake(point_c.x,  point_c.y);
                points[6] = CGPointMake(point_d.x,  point_d.y);
                points[7] = CGPointMake(point_E.x,  point_E.y);
            }
                break;
            case kJBECornerSouthWest:
            {
                points[0] = CGPointMake(point_F.x,  point_F.y);
                points[1] = CGPointMake(point_f.x,  point_f.y);
                points[2] = CGPointMake(point_a.x,  point_a.y);
                points[3] = CGPointMake(point_b.x,  point_b.y);
                points[4] = CGPointMake(point_c.x,  point_c.y);
                points[5] = CGPointMake(point_d.x,  point_d.y);
                points[6] = CGPointMake(point_e.x,  point_e.y);
                points[7] = CGPointMake(point_F.x,  point_f.y);
            }
                break;
            default:
                break;
        }
        
        // 设置巡航帧动画
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddLines(path, NULL, points, sizeof(points)/sizeof(points[0]));
        CAKeyframeAnimation * theAnimation;
        theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
        theAnimation.path = path;
        theAnimation.duration= 2.0f * 7;
        theAnimation.repeatCount = HUGE_VALF;
        theAnimation.delegate = self;
        theAnimation.removedOnCompletion = NO;
        [robot addAnimation:theAnimation forKey:@"RobotNavigate"];
        
        CFRelease(path);
    }
    else
    {
        // 结束机器人巡航 执行机器人回家的动画
        [robot removeAnimationForKey:@"RobotNavigate"];
        CALayer* robotPresentation = robot.presentationLayer;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        robot.position = robotPresentation.position;
        [CATransaction commit];
        
        robot.position = robotHomes[corner];
    }
}

#pragma mark -
#pragma mark 显示或隐藏阴影

-(void)hideTriangleShadow:(JumballCorner)corner hide:(BOOL)hide
{
    CALayer* shadow = triangleShadows[corner];
    if (shadow == nil)
    {
        // 这里并非外接圆半径，而是直径，不过将错就错吧 有需要再改
        //CGFloat center_radius = point_c.x - point_d.x + pieceRadius_ + 3;
        CGFloat center_radius = point_c.x - point_d.x + 2;
        CGFloat triangle_radius = center_radius / sqrtf(3.0f);
        TriangleShadowLayer* shadow = [[[TriangleShadowLayer alloc] initWithRadius:triangle_radius] autorelease];
        CGFloat pi_3 = M_PI / 3;
        
        CATransform3D transform = CATransform3DMakeRotation((3 - corner) * pi_3, 0, 0, 1);
        shadow.transform = CATransform3DTranslate(transform, 0, - triangle_radius * 2, 0);
        shadow.position = CGPointMake(point_O.x, point_O.y);
        [shadow setNeedsDisplay];
        
        [self.layer addSublayer:shadow];
        triangleShadows[corner] = shadow;
    }
    shadow.hidden = hide;
}

-(void)hideCenterShadow:(BOOL)hide
{
    if (centerShadow == nil)
    {
        // 这里并非外接圆半径，而是直径，不过将错就错吧 有需要再改
        //CGFloat center_radius = point_c.x - point_d.x + pieceRadius_ - 2;
        CGFloat center_radius = point_c.x - point_d.x - 2;
        HexagonShadowLayer* shadow = [[[HexagonShadowLayer alloc] initWithRadius:center_radius] autorelease];
        shadow.position = point_O;
        [shadow setNeedsDisplay];
        [self.layer addSublayer:shadow];
        centerShadow = shadow;
    }
    centerShadow.hidden = hide;
}

#pragma mark -
#pragma mark 棋盘规格及颜色设置

// 设置棋盘的宽，以及线段EC包含小线段的数目
-(void)setBoardWidth:(CGFloat)width segmentCount:(int)segmentCount
{
    boardWidth_ = width;
    segmentCount_ = segmentCount;
    [self computeAttributesWithWidth:boardWidth_ segmentCount:segmentCount_];
}

// 设置棋盘六个方位三角形的填充颜色
-(void)setFillColorSouth:(CGColorRef)southColor southEast:(CGColorRef)southEastColor northEast:(CGColorRef)northEastColor north:(CGColorRef)northColor northWest:(CGColorRef)northWestColor southWest:(CGColorRef)southWestColor
{
    cornerFillColors[kJBECornerSouth]       = southColor;
    cornerFillColors[kJBECornerSouthEast]   = southEastColor;
    cornerFillColors[kJBECornerNorthEast]   = northEastColor;
    cornerFillColors[kJBECornerNorth]       = northColor;
    cornerFillColors[kJBECornerNorthWest]   = northWestColor;
    cornerFillColors[kJBECornerSouthWest]   = southWestColor;
}

// 设置棋盘六个 homeCell 的颜色
-(void)setHomeCellColorSouth:(CGColorRef)southColor southEast:(CGColorRef)southEastColor northEast:(CGColorRef)northEastColor north:(CGColorRef)northColor northWest:(CGColorRef)northWestColor southWest:(CGColorRef)southWestColor
{
    cornerCellColors[kJBECornerSouth]       = southColor;
    cornerCellColors[kJBECornerSouthEast]   = southEastColor;
    cornerCellColors[kJBECornerNorthEast]   = northEastColor;
    cornerCellColors[kJBECornerNorth]       = northColor;
    cornerCellColors[kJBECornerNorthWest]   = northWestColor;
    cornerCellColors[kJBECornerSouthWest]   = southWestColor;
}

#pragma mark -
#pragma mark JumballView()

-(void)computeAttributesWithWidth:(int)width segmentCount:(int)segmentCount
{
    segmentCount_ = segmentCount;
    smallSegmentLength_ = width / (segmentCount + 3) + 0.6;
    pieceRadius_ = smallSegmentLength_ * 0.33f;
    homeRadius_ = smallSegmentLength_ * 0.5f;
    
    float sqrt_3 = sqrtf(3.0f);
    float triangleSideLength = smallSegmentLength_ * segmentCount / 3;
    
    // 中心
    // point_O = CGPointMake(width / 2, width / 2);
    
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

- (void) drawBkg:(CGContextRef)ctx
{
    // 线性梯度填充
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGPoint start = CGPointMake(0, 0);
    CGPoint end = CGPointMake(0, self.bounds.size.height);
    
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
    JBGFillTriangle(ctx, point_A, point_a, point_f, cornerFillColors[kJBECornerSouth]);
    JBGFillTriangle(ctx, point_B, point_b, point_a, cornerFillColors[kJBECornerSouthEast]);
    JBGFillTriangle(ctx, point_C, point_c, point_b, cornerFillColors[kJBECornerNorthEast]);
    JBGFillTriangle(ctx, point_D, point_d, point_c, cornerFillColors[kJBECornerNorth]);
    JBGFillTriangle(ctx, point_E, point_e, point_d, cornerFillColors[kJBECornerNorthWest]);
    JBGFillTriangle(ctx, point_F, point_f, point_e, cornerFillColors[kJBECornerSouthWest]);
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
    
    JBGStrokePathByLines(ctx, path, kJBGDarkBlue, w1 * 0.3f, NULL, 0.0f, NULL, 0.0f);
    
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
    // 棋子浅蓝阴影中心
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat lightBlueComponents[4] = {78/255.0f, 215/255.0f, 244/255.0f, 1.0f};
    CGColorRef lightBlue = CGColorCreate(colorSpace, lightBlueComponents);
    const CGColorRef blues[] = {lightBlue, kJBGLightBlue};
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)blues, sizeof(blues) / sizeof(blues[0]), NULL);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, NULL);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(pieceRadius_ * 2, pieceRadius_ * 2), NO,     [UIScreen mainScreen].scale);
    CGContextRef pieceContext =  UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(pieceContext, w1);
    CGPoint center = CGPointMake(pieceRadius_, pieceRadius_);
    JBGFillGradientCircle(pieceContext, center, pieceRadius_ * 0.1, center, pieceRadius_ * 0.8f, gradient, kJBGDarkBlue);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CFRelease(colors);
    CGColorSpaceRelease(colorSpace);
    
    // B D F 顶点对应小三角形内的 cells
    CGContextSetLineWidth(ctx, w1);
    int segmentCount_3 = segmentCount_ / 3;
    CGFloat sqrt_3 = sqrtf(3.0f);
    CGPoint start_points[3];
    start_points[0] = point_D;
    start_points[1] = CGPointMake(point_F.x + smallSegmentLength_ * (segmentCount_3 - 1) / 2, point_F.y - smallSegmentLength_ * (segmentCount_3 - 1) / 2 * sqrt_3);
    start_points[2] = CGPointMake(point_B.x - smallSegmentLength_ * (segmentCount_3 - 1) / 2, point_B.y - smallSegmentLength_ * (segmentCount_3 - 1) / 2 * sqrt_3);
    for (int i = 0; i < 3; ++i)
    {
        CGPoint start_point = start_points[i];
        for (int j = 0; j < segmentCount_ / 3; ++j)
        {
            CGPoint point = CGPointMake(start_point.x - smallSegmentLength_ * 0.5f * j,
                                        start_point.y + smallSegmentLength_ * 0.5f * sqrt_3 * j);
            for (int k = 0; k < j + 1; ++k)
            {
                CGPoint child_point = CGPointMake(point.x + smallSegmentLength_ * k, point.y);
                CGPoint cell_position = CGPointMake(child_point.x - pieceRadius_, child_point.y - pieceRadius_);
                [image drawAtPoint:cell_position];
            }
        }
    }
    
    // 三角形(∆ option + j)
    // ∆ ACE 内的 cells
    for (int i = 0; i < segmentCount_ + 1; ++i)
    {
        CGPoint point = CGPointMake(point_A.x - smallSegmentLength_ * 0.5f * i,
                                    point_A.y - smallSegmentLength_ * 0.5f * sqrt_3 * i);
        for (int j = 0; j < i + 1; ++j)
        {
            CGPoint child_point = CGPointMake(point.x + smallSegmentLength_ * j, point.y);
            CGPoint cell_position = CGPointMake(child_point.x - pieceRadius_, child_point.y - pieceRadius_);
            [image drawAtPoint:cell_position];
        }
    }
}

- (void) setupLayers
{
    // 添加30个脚印
    CGColorRef gray = [UIColor grayColor].CGColor;
    for (int i = 0; i < sizeof(footPrints)/sizeof(footPrints[0]); ++i)
    {
        CursorLayer* cursor  = [[[CursorLayer alloc] initWithCorner:kJBECornerMax color:gray radius:pieceRadius_ * 0.6] autorelease];
        cursor.bounds = CGRectMake(0, 0, pieceRadius_ * 1.6, pieceRadius_ * 1.6);
        cursor.hidden = YES;
        [self.layer addSublayer:cursor];
        footPrints[i] = cursor;
    }
    
    // 添加脚印游标
    footPrintCursor = [[[CursorLayer alloc] initWithCorner:kJBECornerMax color:gray radius:pieceRadius_ * 0.6] autorelease];
    footPrintCursor.bounds = CGRectMake(0, 0, pieceRadius_ * 1.6, pieceRadius_ * 1.6);
    footPrintCursor.hidden = YES;
    [self.layer addSublayer:footPrintCursor];
    
    // 添加棋子游标
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        PieceLayer* piece = [[[PieceLayer alloc] initWithCorner:(JumballCorner)i color:cornerCellColors[i] radius:pieceRadius_] autorelease];
        piece.bounds = CGRectMake(0, 0, pieceRadius_ * 2.3f, pieceRadius_ * 2.3f);
        
        // 计算旋转角度
        CGFloat pi_3 = M_PI / 3;
        piece.transform = CATransform3DMakeRotation(- i * pi_3, 0, 0, 1);
        
        piece.hidden = YES;
        [piece setNeedsLayout];
        
        [self.layer addSublayer:piece];
        pieceCursors[i] = piece;
    }
    
    // 添加箭头游标
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        CursorLayer* cursor = [[[CursorLayer alloc] initWithCorner:(JumballCorner)i color:cornerCellColors[i] radius:pieceRadius_ * 0.6] autorelease];
        cursor.bounds = CGRectMake(0, 0, pieceRadius_ * 1.6, pieceRadius_ * 1.6);
        cursor.hidden = YES;
        [self.layer addSublayer:cursor];
        arrowCursors[i] = cursor;
    }
    
    // 添加机器人
    
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        JumballRobotLayer* robot = [[[JumballRobotLayer alloc] initWithColor:cornerCellColors[i]] autorelease];
        robot.bounds = CGRectMake(0, 0, 24, 36);
        robot.position = CGPointMake(point_A.x + 3, point_A.y - 12);
        robot.hidden = YES;
        [self.layer addSublayer:robot];
        robots[i] = robot;
    }
    
    robots[kJBECornerSouth].position = CGPointMake(point_A.x + 22, point_A.y - 3);
    robotHomes[kJBECornerSouth] = robots[kJBECornerSouth].position;
    
    robots[kJBECornerSouthEast].position = CGPointMake(point_B.x - 3, point_B.y + 22);
    robotHomes[kJBECornerSouthEast] = robots[kJBECornerSouthEast].position;
    
    robots[kJBECornerNorthEast].position = CGPointMake(point_C.x - 3, point_C.y - 8);
    robotHomes[kJBECornerNorthEast] = robots[kJBECornerNorthEast].position;
    
    robots[kJBECornerNorth].position = CGPointMake(point_D.x + 22, point_D.y + 8);
    robotHomes[kJBECornerNorth] = robots[kJBECornerNorth].position;
    
    robots[kJBECornerNorthWest].position = CGPointMake(point_E.x + 3, point_E.y - 8);
    robotHomes[kJBECornerNorthWest] = robots[kJBECornerNorthWest].position;
    
    robots[kJBECornerSouthWest].position = CGPointMake(point_F.x + 3, point_F.y + 22);
    robotHomes[kJBECornerSouthWest] = robots[kJBECornerSouthWest].position;
}

@end
