//
//  ViewController.h
//  Jumball
//
//  Created by Li Xu on 10/6/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniJumballStick.h"
#import "JumballView.h"
#import "JumballGame.h"

@protocol JumballViewDelegate;

@interface ViewController : UIViewController<MiniJumballStickDelegate, JumballViewDelegate, UIAlertViewDelegate>
{
    // 游戏数据及逻辑
    JumballGame* jumballGame;
    
    // 是否用小棋盘
    BOOL mini;
    
    // 选择参与的玩家
    BOOL chooseCorner[kJBECornerMax];
    
    // 先手玩家
    JumballCorner firstCorner;
    
    // 机器人思考操作队列
    NSOperationQueue* queue;
    
    // 检查机器人是否思考完毕的定时器
    NSTimer* timerCheckRobot;
    
    // 配合控制摇柄出发频率
    NSTimeInterval lastStickHitCircle;
}

@property(nonatomic,assign)BOOL mini;
@property(nonatomic,retain)IBOutlet UIButton* buttonPlay;
@property(nonatomic,retain)IBOutlet MiniJumballStick* gameStick;

-(IBAction)actionHelp:(id)sender;
-(IBAction)actionNewGame:(id)sender;
-(IBAction)play:(id)sender;

// 开始新游戏时选择玩家
-(void)choosePlayer:(JumballCorner)corner;

// 游戏进行中召唤机器人
-(void)chooseRobot:(JumballCorner)corner;

@end
