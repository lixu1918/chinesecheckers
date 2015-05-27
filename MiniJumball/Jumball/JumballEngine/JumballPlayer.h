//
//  MiniJumballPlayer.h
//  MiniJumball
//
//  Created by Li Xu on 9/24/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#ifndef MiniJumball_MiniJumballPlayer_h
#define MiniJumball_MiniJumballPlayer_h

#include "JumballEngine.h"
#include "JumballRobot.h"
#include <vector>
#include <map>

class JumballPlayer
{
public:
    JumballPlayer(JumballCorner corner, JumballBoard* board, JumballRule rule, bool mini);
    virtual ~JumballPlayer();
    
public:
    
    const char GetPieceCharacter();
    
    // getter setter
    inline JumballCorner corner(){return corner_;};

    // 到达对角的棋子数
    int ReachDestCount();
    
    // 用棋子初始位置的棋盘索引做为他们的id
    int GetPieceId(int index);
    int GetPieceIdByBoardIndex(int board_index);
    
    // 坐标转换 piece 0 ~ 9  
    void GetPieceViewBoardCoordinate(int piece, int* row, int* column);
    void GetPieceViewBoardHomeCoordinate(int piece, int* row, int* column);
    
    // 1 如果（row column）上是己方棋子的话，设为第一个脚印
    // 2 如果（row column）上是空位，并且最后一个脚印能够到达该空位，则添加做最后一个脚印
    // 3 不能设置为脚印
    bool AddFootPrint(int row, int column);
    int FootPrintCount();
    short GetFootPrint(int index); 
    bool GetFootPrint(int index, int* row, int* column);
    void ClearFootPrints();
    
    // 走子
    /**
     将 footprints_ 中标记选中的棋子 footprints_[0] 移动到 （row，column) 处
     选择的通路将按照从 footprints_ 中从前到后考查某脚印能否到达 (row, column)
     如果整个 footprints 都不能到达，则返回 false
     走子完成后，可能对 footprints 有修正，界面可根据需要调整更新
     */
    bool MoveFootPrintPieceTo(int row, int column);
    
// 机器人相关接口
    
    // 设置托管
    void UseRobot(bool use);
    bool IsUsingRobot();
    
    // 开始思考
    /**
     思考结果保存在footprints
     */
    void BeginThink();
    
    // 是否思考完毕
    /**
     如果思考完毕，则返回真，否则返回假
     */
    bool IsThinkFinish();
    
private:
      
    // 搜索最佳走法
    /**
     如果所有的走法中，有不止一种走法达到最大评分，则他们都会被添加到 moves
     可以在每一次 SearchBestMoves 调用中使用一个 局面 zorbist hash 表
     局面只包括自身棋子，在同一次搜索中，其他玩家的棋子都不会有变化
     hash表应该通过 MJE 函数获取，
     */
    void AddPieceMove(short orignal, short from, std::vector<JumballMove> &moves);
    
    // 打分函数
    /**
     如果 depth == 0, 则返回各个棋子与目的地的距离平方和做为局面打分
     如果 depth != 0, 则返回子局面（走法生成时不包括棋子 last_move ）的打分
     */
    
    // 生成走法
    /**
     如果exclue不为0，那么其指定的某个棋盘索引的棋子不参与走法生成(被视为如同其他玩家的棋子一般)
     */
    void GenerateMoves(short exclude, std::vector<JumballMove> &moves);
    
    void PrintMoves(std::vector<JumballMove> &moves);
    // 打印id-index 和 index-id 映射
    void PrintIdIndexAndIndexIdMap();
    
    // 填充脚印
    /**
     采用分别以 from 和 to 为起点的广度优先搜索，直到2者之间有叶子节点重合，表明两点连通
     */
    void FullFillFootPrints(short original, short from, short to, int depth, std::vector<short> &history_from);
    
    // 玩家方位
    JumballCorner corner_;
    
    // 棋子id做key 棋子在内存棋盘中的索引做value
    std::map<short, short> piece_map_id_index_; 
    // 棋子在内存棋盘中的索引做key，棋子id做value
    std::map<short, short> piece_map_index_id_;
    
    // 脚印
    /**
     第一个脚印表示走动时候选中的棋子
     随后的脚印表示途中经过的点
     最后一个脚印表示到达的目的地
     */
    std::vector<short> footprints_;
    
    // 棋盘
    JumballBoard* board_;
    
    // 是否使用迷你棋盘
    bool mini_;
    
    // 规则
    JumballRule rule_;
    
    // 机器人托管
    bool use_robot_;
    
    // 机器人是否在思考
    bool robot_is_thinking_;
    
    // 机器人
    JumballRobot* robot_;
};

#endif
