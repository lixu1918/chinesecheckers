//
//  ViewController.m
//  Jumball
//
//  Created by Li Xu on 10/6/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import "ViewController.h"
#import "HelpViewController.h"
#include "JumballEngine.h"
#include "JumballGraphics.h"
#include <math.h>

@interface ViewController ()

-(void)beginChooseCorners;
-(void)checkRobot;
-(void)currentRobotThinking:(BOOL)thinking;
-(void)onSingleTap:(UITapGestureRecognizer*)recognizer;
-(void)tapOnCorner:(JumballCorner)corner;
// 如果hide 和 remove 都为真，则将从layer结构中删除棋子
// 如果hide为假，则添加棋子
-(void)hidePiecesOfCorner:(JumballCorner)corner hide:(BOOL)hide remove:(BOOL)remove;
-(void)finishGame;

@end

@implementation ViewController

@synthesize mini;
@synthesize buttonPlay;
@synthesize gameStick;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gameStick.backgroundColor = [UIColor clearColor];
    UIColor* playColor = [UIColor colorWithRed:204 / 255.0f green:224 / 255.0f blue:224 / 255.0f alpha:1];
    [self.buttonPlay setTitleColor:playColor forState:UIControlStateHighlighted];
    [self.buttonPlay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    JumballView* jumballView = (JumballView*)self.view;
    jumballView.delegate = self;
    jumballView.point_O = CGPointMake(self.view.bounds.size.width / 2, sqrtf(3.0f) * self.view.bounds.size.width / 3);
    
    if (mini)
    {
        [jumballView setBoardWidth:self.view.bounds.size.width * 1.235f segmentCount:9];
        [jumballView setFillColorSouth:kJBGDarkRed southEast:kJBGDarkGold northEast:kJBGDarkGreen north:kJBGDarkRed northWest:kJBGDarkGold southWest:kJBGDarkGreen];
        [jumballView setHomeCellColorSouth:kJBGRed southEast:kJBGGold northEast:kJBGGreen north:kJBGRed northWest:kJBGGold southWest:kJBGGreen];
    } else
    {
        [jumballView setBoardWidth:self.view.bounds.size.width * 1.15f segmentCount:12];
        [jumballView setFillColorSouth:kJBGDarkRed southEast:kJBGDarkGreen northEast:kJBGDarkPink north:kJBGDarkGold northWest:kJBGDarkPurple southWest:kJBGDarkYellow];
        [jumballView setHomeCellColorSouth:kJBGRed southEast:kJBGGreen northEast:kJBGPink north:kJBGGold northWest:kJBGPurple southWest:kJBGYellow];
    }
    
    [jumballView setupLayers];
    [jumballView setNeedsDisplay];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
    if (jumballGame)
    {
        // 说明 jumballView 因为内存紧张被销毁 并且正处于游戏或者gameover阶段
        
        // 不论如何，首先恢复棋盘上的棋子
        
        // 显示当前走子玩家的游标
        
        // 脚印就不恢复了
        
        if (jumballGame->IsGameOver())
        {
            // 说明游戏已经结束 添加游戏结束阴影
            for (int i = 0; i < kJBECornerMax; ++i)
            {
                [jumballView hideTriangleShadow:(JumballCorner)i hide:NO];
            }
        }
    }
    else
    {
        // 说明 jumballView 因为内存紧张被销毁 并且正处于选择参与玩家阶段
        // 需要根据已经选择的corner恢复界面
        [self beginChooseCorners];
        if (firstCorner != kJBECornerMax)
        {
            for (int i = 0; i < kJBECornerMax; ++i)
            {
                if (chooseCorner[i])
                {
                    [jumballView hideTriangleShadow:(JumballCorner)i hide:YES];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    //return NO;
}


#pragma mark - 选择参与玩家

-(void)choosePlayer:(const JumballCorner)corner
{
    // 如果是之前已经选择过，那么属于 unchoose
    bool unchoose = chooseCorner[corner];
    
    chooseCorner[corner] = !chooseCorner[corner];
    if (mini)
    {
        JumballCorner diagnal = JBEDiagonalCorner(corner);
        chooseCorner[diagnal] = !chooseCorner[diagnal];
    }
    
    // 更新阴影
    JumballView* jumballView = (JumballView*)self.view;
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        [jumballView hideTriangleShadow:(JumballCorner)i hide:chooseCorner[i]];
    }
    
    // 点亮的corner数
    int playerCount = 0;
    JumballCorner choosedCorner = kJBECornerMax;
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        if (chooseCorner[i])
        {
            ++playerCount;
            choosedCorner = (JumballCorner)i;
        }
    }
    
    // 确定先手玩家
    if (!unchoose)
    {
        if (playerCount == 1 && !mini)
        {
            firstCorner = choosedCorner;
        }
        else if (playerCount == 2 && mini)
        {
            for (int i = 0; i < 3; ++i) {
                if (chooseCorner[i + i])
                {
                    firstCorner = (JumballCorner)(i + i);
                    break;
                }
            }
        }
    }
    else
    {
        if (playerCount == 0)
        {
            firstCorner = kJBECornerMax;
        }
        else if (firstCorner == corner)
        {
            if (mini)
            {
                for (int i = 0; i < 3; ++i)
                {
                    JumballCorner newChoose = (JumballCorner)( (firstCorner + i + i) % kJBECornerMax);
                    if (chooseCorner[newChoose])
                    {
                        firstCorner = newChoose;
                        break;
                    }
                }
            } else
            {
                for (int i = 0; i < kJBECornerMax; ++i)
                {
                    JumballCorner newChoose = (JumballCorner)( (firstCorner + i) % kJBECornerMax);
                    if (chooseCorner[newChoose])
                    {
                        firstCorner = newChoose;
                        break;
                    }
                }
            }
        }
    }
    
    // 更新 play 按钮
    if (mini)
    {
        // 小棋盘选中参与玩家数应该是 0 2 4 6
        self.buttonPlay.hidden = playerCount < 4;
    }
    else
    {
        if (playerCount == 2 || playerCount == 6)
        {
            // 2 或者 6 个玩家，不论他们的位置关系如何，总是可以开始的
            self.buttonPlay.hidden = NO;
        }
        else if (playerCount == 3)
        {
            // 3 个玩家：如果有两个玩家对角，则有利于第三个玩家，所以需要保证
            // 每一个被选中的玩家对角都为空
            // 另外：如果3个玩家之间没有空位（相邻），则有利于在中间的玩家，也不予支持
            BOOL hidePlay = NO;
            for (int i = 0; i < kJBECornerMax; ++i)
            {
                if (chooseCorner[i] && chooseCorner[JBEDiagonalCorner(i)])
                {
                    hidePlay = YES;
                    break;
                }
                else if (chooseCorner[i] && chooseCorner[(i + 1)%kJBECornerMax])
                {
                    hidePlay = YES;
                    break;
                }
            }
            self.buttonPlay.hidden = hidePlay;
        }
        else if (playerCount == 4)
        {
            // 4 个玩家：只有2个空位，最多有两个玩家对角为空，这样对另外两个玩家不利
            // 所以需要保证，每个玩家对角都被选中
            BOOL hidePlay = NO;
            for (int i = 0; i < kJBECornerMax; ++i)
            {
                if (chooseCorner[i] && !chooseCorner[JBEDiagonalCorner(i)])
                {
                    hidePlay = YES;
                    break;
                }
            }
            self.buttonPlay.hidden = hidePlay;
        }
        else
        {
            // 如果是 0 1 5 是不能进行游戏的
            self.buttonPlay.hidden = YES;
        }
    }
    
    // 显示或隐藏棋子
    if (!self.buttonPlay.hidden)
    {
        [self.view bringSubviewToFront:self.buttonPlay];
        
        // 显示相应棋子
        for (int i = 0; i < kJBECornerMax; ++i)
        {
            if (chooseCorner[i])
            {
                if (!mini || (mini && (i % 2 == 0)))
                {
                    [self hidePiecesOfCorner:(JumballCorner)i hide:NO remove:NO];
                }
            }
            else
            {
                if (!mini || (mini && (i % 2 == 0)))
                {
                    [self hidePiecesOfCorner:(JumballCorner)i hide:YES remove:YES];
                }
            }
        }
    }
    else
    {
        // 隐藏所有棋子
        // 显示相应棋子
        for (int i = 0; i < kJBECornerMax; ++i)
        {
            [self hidePiecesOfCorner:(JumballCorner)i hide:YES remove:YES];
        }
    }
}

#pragma mark - 召唤机器人

-(void)chooseRobot:(JumballCorner)corner
{
    // 设置托管
    JumballPlayer* player = jumballGame->PlayerOfCorner(corner);
    if (player == NULL)
        return;
    
    JumballView* jumballView = (JumballView*)self.view;
    
    if (player->IsUsingRobot())
    {
        player->UseRobot(false);
        [jumballView hideRobot:player->corner() hide:YES];
        
        // 如果正轮到当前机器人， 则应该终止机器人思考的线程, 终止机器人巡航,停止 checkRobot 定时器, 并启用手柄
        JumballPlayer* current_player = jumballGame->CurrentPlayer();
        if (current_player == player)
        {
            self.gameStick.userInteractionEnabled = YES;
            [self currentRobotThinking:NO];
            
            // 显示玩家光标
            if (player->FootPrintCount() > 0) {
                
                int row, column;
                if (player->GetFootPrint(0, &row, &column))
                {
                    [jumballView addArrowCursor:player->corner() toRow:row column:column];
                }
                // 清除脚印
                player->ClearFootPrints();
            } else {
                
                //  说明第一次轮到该玩家
                int pieceIndex = random() % 4 + 6;
                int row, column;
                player->GetPieceViewBoardHomeCoordinate(pieceIndex, &row, &column);
                [jumballView addArrowCursor:player->corner() toRow:row column:column];
            }
        }
    }
    else
    {
        player->UseRobot(true);
        [jumballView hideRobot:player->corner() hide:NO];
        
        JumballPlayer* current_player = jumballGame->CurrentPlayer();
        if (current_player == player)
        {
            self.gameStick.userInteractionEnabled = NO;
            [self currentRobotThinking:YES];
        }
    }
}

#pragma mark -
#pragma mark - ViewController ()

-(void)hidePiecesOfCorner:(JumballCorner)corner hide:(BOOL)hide remove:(BOOL)remove
{
    JumballView* jumballView = (JumballView*)self.view;
    const short* indexes = NULL;
    if (mini)
        indexes = kJBEMiniPieceIdTables[corner];
    else
        indexes = kJBEPieceIdTables[corner];

    for (int i = 0; i < kJBEPieceCount; ++i)
    {
        int pieceId = indexes[i];
        if (hide)
        {
            [jumballView hidePieceOfKey:pieceId hide:YES];
        }
        else
        {
            [jumballView addPieceOfCorner:corner pieceId:pieceId];
            int row, column;
            JBEIndexToRowColumn(pieceId, &row, &column);
            [jumballView movePieceOfKey:pieceId toRow:row column:column];
        }
    }
}

-(void)tapOnCorner:(JumballCorner)corner
{
    if (jumballGame == NULL)
    {
        [self choosePlayer:corner];
    }
    else if (!jumballGame->IsGameOver())
    {
        if (chooseCorner[corner]) {
            if ((mini && (corner % 2 == 0)) || !mini) {
                [self chooseRobot:corner];
            }
        }
    }
}

-(BOOL)triangleContainsPoint:(CGPoint)point trianglePointA:(CGPoint)point_a pointB:(CGPoint)point_b pointC:(CGPoint)point_c
{
    float min_x, max_x, min_y, max_y;
    if (point_a.x < point_b.x)
    {
        min_x = point_a.x;
        max_x = point_b.x;
    }
    else
    {
        min_x = point_b.x;
        max_x = point_a.x;
    }
    min_x = min_x < point_c.x ? min_x : point_c.x;
    max_x = max_x > point_c.x ? max_x : point_c.x;
    
    if (point_a.y < point_b.y)
    {
        min_y = point_a.y;
        max_y = point_b.y;
    }
    else
    {
        min_y = point_b.y;
        max_y = point_a.y;
    }
    min_y = min_y < point_c.y ? min_y : point_c.y;
    max_y = max_y > point_c.y ? max_y : point_c.y;
    
    BOOL tapOnTriangle = NO;
    if (point.x > min_x && point.x < max_x && point.y > min_y && point.y < max_y)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint triangle[] = {point_a, point_b, point_c};
        CGPathAddLines(path, NULL, triangle, 3);
        CGPathCloseSubpath(path);
        tapOnTriangle = CGPathContainsPoint(path, NULL, point, NO);
        CGPathRelease(path);
    }
    return tapOnTriangle;
}

-(void)onSingleTap:(UITapGestureRecognizer*)recognizer
{
    JumballView* jumballView = (JumballView*)self.view;
    CGPoint point = [recognizer locationInView:self.view];
    
    if ([self triangleContainsPoint:point trianglePointA:jumballView.point_A pointB:jumballView.point_f pointC:jumballView.point_a])
    {
        [self tapOnCorner:kJBECornerSouth];
    }
    else if ([self triangleContainsPoint:point trianglePointA:jumballView.point_B pointB:jumballView.point_a pointC:jumballView.point_b])
    {
        [self tapOnCorner:kJBECornerSouthEast];
    }
    else if ([self triangleContainsPoint:point trianglePointA:jumballView.point_C pointB:jumballView.point_b pointC:jumballView.point_c])
    {
        [self tapOnCorner:kJBECornerNorthEast];
    }
    else if ([self triangleContainsPoint:point trianglePointA:jumballView.point_D pointB:jumballView.point_c pointC:jumballView.point_d])
    {
        [self tapOnCorner:kJBECornerNorth];
    }
    else if ([self triangleContainsPoint:point trianglePointA:jumballView.point_E pointB:jumballView.point_d pointC:jumballView.point_e])
    {
        [self tapOnCorner:kJBECornerNorthWest];
    }
    else if ([self triangleContainsPoint:point trianglePointA:jumballView.point_F pointB:jumballView.point_e pointC:jumballView.point_f])
    {
        [self tapOnCorner:kJBECornerSouthWest];
    }
}

/**
 * 原来开始选择的时候，是默认一个都不选
 * 现更改为全选，并默认 kCornerSouth 先手
 */
-(void)beginChooseCorners
{
    JumballView* boardview = (JumballView*)self.view;
    
    // 复位选择
    firstCorner = kJBECornerMax;
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        chooseCorner[i] = NO;
    }
    
    // 隐藏开始按钮
    self.buttonPlay.hidden = NO;
    
    // 添加中心阴影层
    [boardview hideCenterShadow:NO];
    
    // 隐藏三角形阴影，并添加全部棋子
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        [boardview hideTriangleShadow:(JumballCorner)i hide:YES];
        if ((mini && ((i % 2) == 0)) || !mini)
        {
            //[self hidePiecesOfCorner:(JumballCorner)i hide:NO remove:NO];
            [self tapOnCorner:(JumballCorner)i];
        }
    }
}

-(void)currentRobotBeginThingking
{
    JumballPlayer* currentPlayer = NULL;
    if (jumballGame) {
        currentPlayer = jumballGame->CurrentPlayer();
    }
    
    if (currentPlayer) {
        
        currentPlayer->BeginThink();
    }
}

-(void)currentRobotThinking:(BOOL)thinking
{
    // 获取当前player
    JumballView* boardView = (JumballView*)self.view;
    JumballPlayer* currentPlayer = NULL;
    if (jumballGame) {
        currentPlayer = jumballGame->CurrentPlayer();
    }
    
    if (thinking)
    {
        if (currentPlayer) {
            
            // 开始巡航
            [boardView navigateRobot:currentPlayer->corner() navigate:YES];
            
            // 开始在后台线程思考
            if (queue == nil)
            {
                queue = [[NSOperationQueue alloc] init];
            }
            
            NSInvocationOperation* operation = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(currentRobotBeginThingking) object:nil] autorelease];
            
            [queue addOperation:operation];
            
            // 开启定时器 check robot
            [timerCheckRobot invalidate];
            
            // 延时3s，给用户时间取消机器人
            dispatch_after(
                           dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC),
                           dispatch_get_current_queue(),
                           ^{
                               timerCheckRobot = [NSTimer scheduledTimerWithTimeInterval: 3.0f
                                                                                  target: self
                                                                                selector:@selector(checkRobot)
                                                                                userInfo: nil repeats:YES];
                           }
                           );
        }
    }
    else
    {
        if (currentPlayer) {
            
            // 结束巡航
            [boardView navigateRobot:currentPlayer->corner() navigate:NO];
            
            // 取消定时器
            [timerCheckRobot invalidate];
            timerCheckRobot = nil;
            
            if (queue) {
                [queue cancelAllOperations];
            }
        }
    }
}

-(void)checkRobot
{
    if (jumballGame) {
        
        JumballPlayer* player = jumballGame->CurrentPlayer();
        
        if (player) {
            
            if (player->IsThinkFinish()) {
                
                JumballView* boardView = (JumballView*)self.view;
                int footprint_count = player->FootPrintCount();
                
                [boardView navigateRobot:player->corner() navigate:NO];
                [timerCheckRobot invalidate];
                timerCheckRobot = nil;
                
                if (footprint_count >= 2) {
                    
                    short footprint = player->GetFootPrint(footprint_count - 1);
                    int row, column;
                    JBEIndexToRowColumn(footprint, &row, &column);
                    
                    [boardView addArrowCursor:player->corner() toRow:row column:column];
                    [self doubleTapOnCenterButton:nil];
                }
            } else {
                
                return;
            }
        }
    } else {
        
        [timerCheckRobot invalidate];
        timerCheckRobot = nil;
    }
}


-(void)finishGame
{
    if (jumballGame) {
        
        JumballView* jumballView = (JumballView*)self.view;
        
        for (int i = 0; i < kJBECornerMax; ++i)
        {
            [self hidePiecesOfCorner:(JumballCorner)i hide:YES remove:YES];
            // 隐藏机器人
            [jumballView hideRobot:(JumballCorner)i hide:YES];
            // 隐藏箭头游标
            [jumballView removeArrowCursor:(JumballCorner)i];
        }
        
        // 移走脚印s
        [jumballView removeFootPrints];
        
        delete jumballGame;
        jumballGame = NULL;
    }
}

#pragma mark -
#pragma mark - actions

-(IBAction)actionHelp:(id)sender
{
    HelpViewController* helpViewController = [[[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:helpViewController animated:YES];
}

-(IBAction)play:(id)sender
{
    buttonPlay.hidden = YES;
    JumballView* jumballView = (JumballView*)self.view;
    [jumballView hideCenterShadow:YES];
    for (int i = 0; i < kJBECornerMax; ++i) {
        [jumballView hideTriangleShadow:(JumballCorner)i hide:YES];
    }

    // 创建 miniJumballGame 实例
    JumballRule rule = kJBEScroll | kJBEShortJump | kJBELongJump | kJBELongLongJump;
    if (mini)
        jumballGame = new JumballGame(chooseCorner[kJBECornerSouth], chooseCorner[kJBECornerNorthEast], chooseCorner[kJBECornerNorthWest], firstCorner, rule);
     else 
         jumballGame = new JumballGame(chooseCorner[kJBECornerSouth], chooseCorner[kJBECornerSouthEast], chooseCorner[kJBECornerNorthEast], chooseCorner[kJBECornerNorth], chooseCorner[kJBECornerNorthWest], chooseCorner[kJBECornerSouthWest], firstCorner, rule);
  
    self.gameStick.userInteractionEnabled = YES;
    
    // 处理当前玩家
    
    JumballPlayer* currentPlayer = jumballGame->CurrentPlayer();
    
    // 第 6 7 8 9 个棋子的位置都适合放置光标
    //     // 一旦 miniJumballGame != NULL 手柄开始接受用户输入.....
    int pieceIndex = random() % 4 + 6;
    int row, column;
    currentPlayer->GetPieceViewBoardHomeCoordinate(pieceIndex, &row, &column);
    [jumballView addArrowCursor:currentPlayer->corner() toRow:row column:column];
}

-(IBAction)actionNewGame:(id)sender
{
    if (jumballGame == NULL)
    {
        [self beginChooseCorners];
    }
    else if (jumballGame->IsGameOver())
    {
        [self finishGame];
        [self beginChooseCorners];
    } else {
        
        // 弹出警告对话框 提示正在游戏中
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Game is still in progress" message:@"Are you sure to begin a new game?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark -
#pragma mark MiniJumballViewDelegate

-(void)pieceCursorStopMoving:(JumballCorner)corner
{
    if (jumballGame) {
        
        JumballPlayer* player = jumballGame->PlayerOfCorner(corner);
        
        if (player) {
            
            JumballView* boardview = (JumballView*)self.view;
            for (int i = 0; i < kJBEPieceCount; ++i)
            {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [boardview hidePieceOfKey:player->GetPieceId(i) hide:NO];
                [CATransaction commit];
            }
        }
    }
}

#pragma mark -
#pragma mark MiniJumballStickDelegate

-(void)doubleTapOnCenterButton:(id)sender
{
    JumballPlayer* player = NULL;
    if (jumballGame) {
        player =  jumballGame->CurrentPlayer();
    }
    
    if (player == NULL) {
        return;
    }
    
    JumballView* jumballView = (JumballView*)self.view;
    
    // 获取当前光标的坐标
    int row, column;
    if (![jumballView coordinateOfArrowCurser:player->corner() row:&row column:&column])
    {
        return;
    }
    
    // 问 player ，能否完成走子到该位置， 如果完成则将棋子移动到双击处
    if (player->MoveFootPrintPieceTo(row, column))
    {
        // 获取脚印，并交给 jumballView 用于更新
        [jumballView removeFootPrints];
        int footprintCount = player->FootPrintCount();
        for (int i = 0; i < footprintCount; ++i)
        {
            int row, column;
            CALayer* footprint = nil;
            if (player->GetFootPrint(i, &row, &column))
            {
                footprint = [jumballView addFootPrintRow:row column:column];
            }
            
            if (footprintCount == 1) {
                
                // 只有一个脚印，刚选中棋子的状态
                
                CGFloat pi_3 = M_PI / 3;
                [jumballView rotateLayer:footprint toAngle:- player->corner() * pi_3];
                
            } else if (i == footprintCount - 1)
            {
                // 最后一个脚印，方向同上一个脚印
                int from_row, from_column;
                if (player->GetFootPrint(i - 1, &from_row, &from_column))
                {
                    
                    JumballDirection direction = JBEDirectionByRowColumn(from_row, from_column, row, column);
                    if (direction != kJBEDirectionMax) {
                        [jumballView rotateLayer:footprint toDirection:direction];
                    }
                }
            } else {
                
                // 脚印数大于1时，且非最后一个脚印，脚印指向下一个脚印
                int to_row, to_column;
                if (player->GetFootPrint(i + 1, &to_row, &to_column))
                {
                    
                    JumballDirection direction = JBEDirectionByRowColumn(row, column, to_row, to_column);
                    if (direction != kJBEDirectionMax) {
                        
                        [jumballView rotateLayer:footprint toDirection:direction];
                    }
                }
            }
        }
        
        // 走子动画 把从起点到终点的一串接力动画(贞动画)
        NSMutableArray* points = [NSMutableArray array];
        for (int i = 0; i < footprintCount; ++i) {
            
            int piece_row, piece_column;
            if (player->GetFootPrint(i, &piece_row, &piece_column))
            {
                NSValue* pointValue = [NSValue valueWithCGPoint:CGPointMake(piece_row, piece_column)];
                [points addObject:pointValue];
            }
        }
        [jumballView movePieceCursor:player->corner() along:points];
        
        // 先隐藏，再移动棋子(注意此时内存模型中，棋子已经到达目的地了)
        int piece_id = player->GetPieceIdByBoardIndex(player->GetFootPrint(footprintCount - 1));
        [jumballView hidePieceOfKey:piece_id hide:YES];
        int dest_row, dest_column;
        player->GetFootPrint(footprintCount - 1, &dest_row, &dest_column);
        [jumballView movePieceOfKey:piece_id toRow:dest_row column:dest_column];
        
        
        // 走棋完成 换人 如果只有当前玩家还没有全部到达终点，则返回当前玩家
        // 如果返回 false 说明全部玩家都已经到达终点了
        if(jumballGame->ChangePlayer())
        {
            // 添加相应的光标-不移除脚印
            [jumballView removeArrowCursor:player->corner()];
            player = jumballGame->CurrentPlayer();
            
            // 如果 player 是用机器人托管 那么
            if (player->IsUsingRobot())
            {
                gameStick.userInteractionEnabled = NO;
                [self currentRobotThinking:YES];
            }
            else
            {
                // 启用手柄
                gameStick.userInteractionEnabled = YES;
                
                if (player->FootPrintCount() > 0) {
                    
                    int row, column;
                    if (player->GetFootPrint(0, &row, &column))
                    {
                        [jumballView addArrowCursor:player->corner() toRow:row column:column];
                    }
                    // 清除脚印
                    player->ClearFootPrints();
                } else {
                    
                    //  说明第一次轮到该玩家
                    int pieceIndex = random() % 4 + 6;
                    int row, column;
                    player->GetPieceViewBoardHomeCoordinate(pieceIndex, &row, &column);
                    [jumballView addArrowCursor:player->corner() toRow:row column:column];
                }
            }
        } else {
            
            // 判断当前玩家的棋子是否全部到达目的地，没有则让玩家继续进行
            if (jumballGame->IsGameOver())
            {
                int player_count = jumballGame->PlayerCount();
                
                for (int i = 0; i < player_count; ++i)
                {
                    JumballPlayer* finishPlayer = jumballGame->ReachDestPlayer(i);
                    [jumballView hideTriangleShadow:JBEDiagonalCorner(finishPlayer->corner()) hide:NO];
                    //[jumballView addShadowForCorner:JBEDiagonalCorner(finishPlayer->corner())];
                }
            }
            
            //  说明其他人已经到达终点了，那么，不做处理，玩家继续操作
        }
    }
}

-(void)tapOnCenterButton:(id)sender
{
    
    JumballPlayer* player = NULL;
    if (jumballGame) {
        player =  jumballGame->CurrentPlayer();
    }
    
    if (player == NULL) {
        return;
    }
    
    JumballView* jumballView = (JumballView*)self.view;
    
    // 获取当前光标的坐标
    int row, column;
    if (![jumballView coordinateOfArrowCurser:player->corner() row:&row column:&column])
    {
        return;
    }
    
    // 问player，当前 (row column) 能否被添加到脚印中
    // 如果返回真，则说明当前位置已经添加到脚印，并且，该player的脚印已经改变，需要更新界面里的脚印
    if (player->AddFootPrint(row, column))
    {
        // 获取脚印，并交给 jumballView 用于更新
        [jumballView removeFootPrints];
        int footprintCount = player->FootPrintCount();
        for (int i = 0; i < footprintCount; ++i)
        {
            int row, column;
            CALayer* newFootPrint = nil;
            if (player->GetFootPrint(i, &row, &column))
            {
                newFootPrint = [jumballView addFootPrintRow:row column:column];
            }
            
            if (footprintCount == 1) {
                CGFloat pi_3 = M_PI / 3;
                [jumballView rotateLayer:newFootPrint toAngle:- player->corner() * pi_3];
                [jumballView moveFootPrintCursorFromRow:row column:column toRow:row toColumn:column forCorner:player->corner()];
            } else if (i == footprintCount - 1)
            {
                // 最后一个脚印，方向同上一个脚印
                int from_row, from_column;
                if (player->GetFootPrint(i - 1, &from_row, &from_column))
                {
                    
                    JumballDirection direction = JBEDirectionByRowColumn(from_row, from_column, row, column);
                    if (direction != kJBEDirectionMax) {
                        [jumballView rotateLayer:newFootPrint toDirection:direction];
                        [jumballView moveFootPrintCursorFromRow:from_row column:from_column toRow:row toColumn:column forCorner:player->corner()];
                    }
                }
            } else {
                // 脚印数大于1时，且非最后一个脚印，脚印指向下一个脚印
                int to_row, to_column;
                if (player->GetFootPrint(i + 1, &to_row, &to_column))
                {
                    
                    JumballDirection direction = JBEDirectionByRowColumn(row, column, to_row, to_column);
                    if (direction != kJBEDirectionMax) {
                        [jumballView rotateLayer:newFootPrint toDirection:direction];
                    }
                }
            }
        }
    }
}

-(void)stickHitCircle:(id)sender radius:(float)radius
{
    static const float pi_6 = M_PI / 6;
    static const float pi_2 = M_PI_2;
    static const float pi_5_6 = M_PI - pi_6;
    // 每次连续操作间隔 0.5s
    static NSTimeInterval silent_duration = 0.4;
    
    JumballView* jumballView = (JumballView*)self.view;
    
    JumballPlayer* player = NULL;
    if (jumballGame) {
        player = jumballGame->CurrentPlayer();
    }
    
    if (!player) {
        return;
    }
    
    JumballCorner corner = player->corner();
    
    // 处理旋转光标
    JumballDirection direction = kJBEDirectionMax;
    
    if (pi_6 < radius && pi_2 > radius) {
        
        // 右上
        direction = kJBEDirectionNorthEast;
        
    } else if (pi_2 < radius && pi_5_6 > radius) {
        // 左上
        direction = kJBEDirectionNorthWest;
        
        
    } else if ((pi_5_6 < radius && M_PI > radius)
               || (-M_PI < radius && - pi_5_6 > radius))
    {
        // 左
        direction = kJBEDirectionWest;
        
    } else if (- pi_5_6 < radius && - pi_2 > radius)
    {
        // 左下
        direction = kJBEDirectionSouthWest;
        
    } else if (- pi_2 < radius && - pi_6 > radius)
    {
        // 右下
        direction = kJBEDirectionSouthEast;
        
        
    } else if ((- pi_6 < radius && - 0.000001 > radius)
               || (0.000001 < radius && pi_5_6 > radius))
    {
        // 右
        direction = kJBEDirectionEast;
    }
    
    // 处理旋转光标
    if (direction != kJBEDirectionMax) {
        
        [jumballView rotateArrowCursor:corner toDirection:direction];
    }
    
    
    // 处理移动光标
    NSTimeInterval current_hit_time = [NSDate timeIntervalSinceReferenceDate];
    if (current_hit_time - lastStickHitCircle > silent_duration) {
        
        if (direction != kJBEDirectionMax) {
            [jumballView moveArrowCursor:corner direction:direction];
            lastStickHitCircle = current_hit_time;
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // 清除旧游戏，开始新游戏
        [self finishGame];
        [self beginChooseCorners];
    }
}

@end
