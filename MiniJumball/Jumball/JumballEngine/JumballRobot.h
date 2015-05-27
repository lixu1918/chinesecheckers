//
//  MiniJumballRobot.h
//  MiniJumball
//
//  Created by Li Xu on 10/4/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#ifndef MiniJumball_MiniJumballRobot_h
#define MiniJumball_MiniJumballRobot_h

#include "JumballEngine.h"
#include <map>
#include <vector>

class JumballRobot
{
public:
    JumballRobot(JumballCorner corner, JumballRule rule, bool mini);
    virtual ~JumballRobot();
    
public:
    void ResetJumballBoard(JumballBoard board, const std::map<short, short> &piece_map_id_index, const std::map<short, short> &piece_map_index_id);
    void SearchBestMoves(std::vector<JumballMove> &best_moves, int depth);
    
private:
    // 生成走法
    /**
     如果exclue不为0，那么其指定的某个棋盘索引的棋子不参与走法生成(被视为如同其他玩家的棋子一般)
     */
    int Evaluate(short last_moved, int depth);
    void AddPieceMove(short orignal, short from, std::vector<JumballMove> &moves);
    void GenerateMoves(short exclude, std::vector<JumballMove> &moves);
    void PrintMoves(std::vector<JumballMove> &moves);
    
    // 走子 撤销走子
    /**
     修改棋盘内存和 id-index map index-id map
     */
    void DoMove(JumballMove move);
    void UndoMove(JumballMove move);
    
private:
    
    JumballCorner corner_;
    
    // 规则
    JumballRule rule_;
    
    // 棋子id做key 棋子在内存棋盘中的索引做value
    std::map<short, short> piece_map_id_index_; 
    
    // 棋子在内存棋盘中的索引做key，棋子id做value
    std::map<short, short> piece_map_index_id_;
    
    // 机器人棋盘
    JumballBoard board_;
    // 是否使用迷你棋盘
    bool mini_;
};

#endif
