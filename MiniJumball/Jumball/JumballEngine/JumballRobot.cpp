//
//  MiniJumballRobot.cpp
//  MiniJumball
//
//  Created by Li Xu on 10/4/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#include "JumballRobot.h"
#include <iostream>
#include <assert.h>

JumballRobot::JumballRobot(JumballCorner corner, JumballRule rule, bool mini)
{
    corner_ = corner;
    rule_ = rule;
    mini_ = mini;
}

JumballRobot::~JumballRobot()
{

}

void JumballRobot::ResetJumballBoard(JumballBoard board, const std::map<short, short> &piece_map_id_index, const std::map<short, short> &piece_map_index_id)
{
    memcpy(board_, board, sizeof(board_));
    
    piece_map_id_index_.clear();
    piece_map_id_index_.insert(piece_map_id_index.begin(), piece_map_id_index.end());
    
    piece_map_index_id_.clear();
    piece_map_index_id_.insert(piece_map_index_id.begin(), piece_map_index_id.end());
}

void JumballRobot::AddPieceMove(short orignal, short from, std::vector<JumballMove> &moves)
{
    const JumballBoard* bool_board = NULL;
    if (mini_) {
        bool_board = &kJBEMiniBoolBoard;
    } else {
        bool_board = &kJBEBoolBoard;
    }
    
    // 6 个方向
    for (int j = 0; j < kJBEDirectionMax; ++j) {
        
        int unit_step = kJBEUnitStep[j];
        int two_unit_step = unit_step + unit_step;
        
        // scroll 只有 原始起点和当前的from相同的时候，才能 scroll
        if (rule_ & kJBEScroll && orignal == from) {
            
            short to = from + unit_step;
            
            if (!board_[to] && (*bool_board)[to]) {
                
                JumballMove move = JBEMakeMove(orignal, to);
                
                if (std::find(moves.begin(), moves.end(), move) == moves.end())
                {
                    // 该位置不曾搜索过
                    moves.push_back(move);
                    // 第一步如果是滚动，则不能在此基础上再跳了
                    //AddPieceMove(orignal, to, moves);
                }
            }
        }
        
        // short jump
        if (rule_ & kJBEShortJump) 
        {
            short to = from + two_unit_step;
            short bridge = from + unit_step;
            // 还必须满足一个条件，就是 original 不能做 bridge
            if (bridge >= 0 &&
                bridge < sizeof(JumballBoard) &&
                to >= 0 && to <
                sizeof(JumballBoard) &&
                !board_[to] && board_[bridge] && 
                (*bool_board)[bridge] &&
                (*bool_board)[to] &&
                orignal != bridge) 
            {
                JumballMove move = JBEMakeMove(orignal, to);
                if (std::find(moves.begin(), moves.end(), move) == moves.end()) 
                {
                    moves.push_back(move);
                    //DoMove(move);
                    AddPieceMove(orignal, to, moves);  
                    //UndoMove(move);
                } 
            }
        }
        
        // long jump
        if (rule_ & kJBELongJump)
        {
            short bridge = from + two_unit_step;
            short to = bridge + two_unit_step;
            if (bridge >= 0 && bridge < sizeof(JumballBoard) &&
                to >= 0 && to < sizeof(JumballBoard) &&
                !board_[bridge - unit_step] && 
                board_[bridge] && 
                !board_[bridge + unit_step] && 
                !board_[to] && 
                (*bool_board)[bridge] &&
                (*bool_board)[to] &&
                orignal != bridge) 
            {
                JumballMove move = JBEMakeMove(orignal, to);
                if (std::find(moves.begin(), moves.end(), move) == moves.end()) 
                {
                    moves.push_back(move);
                    //DoMove(move);
                    AddPieceMove(orignal, to, moves);  
                    //UndoMove(move);
                } 
            }
        }
        
        // long long jump
        if (rule_ & kJBELongLongJump)
        {
            short bridge = from + two_unit_step + unit_step;
            short to = bridge + two_unit_step + unit_step;
            if (bridge >= 0 &&
                bridge < sizeof(JumballBoard) &&
                to >= 0 && to < sizeof(JumballBoard) &&
                !board_[bridge - two_unit_step] &&
                !board_[bridge - unit_step] &&
                board_[bridge] && 
                !board_[bridge + unit_step] &&
                !board_[bridge + two_unit_step] &&
                !board_[to] && 
                (*bool_board)[bridge] &&
                (*bool_board)[to] &&
                orignal != bridge)
            {
                JumballMove move = JBEMakeMove(orignal, to);
                if (std::find(moves.begin(), moves.end(), move) == moves.end()) 
                {
                    moves.push_back(move);
                    //DoMove(move);
                    AddPieceMove(orignal, to, moves);  
                    //UndoMove(move);
                } 
            }
        }
    }
}

void JumballRobot::GenerateMoves(short exclude, std::vector<JumballMove> &moves)
{
    assert(moves.size() == 0);
    
    const short* identifiers = NULL;
    if (mini_)
    {
        identifiers = kJBEMiniPieceIdTables[corner_];
    }
    else
    {
        identifiers = kJBEPieceIdTables[corner_];
    }
    
    for (int i = 0; i < kJBEPieceCount; ++i) {
        
        const short piece_id = identifiers[i];
        std::map<short, short>::iterator iter = piece_map_id_index_.find(piece_id);
        assert(iter != piece_map_id_index_.end());
        short from = iter->second;
        
        if (from == exclude) {
            continue;
        }
        
        std::vector<JumballMove> piece_moves;
        AddPieceMove(from, from, piece_moves);
        
        std::vector<JumballMove>::iterator begin = piece_moves.begin();
        std::vector<JumballMove>::iterator end = piece_moves.end();
        moves.insert(moves.end(), begin, end);
    }
}

void JumballRobot::SearchBestMoves(std::vector<JumballMove> &best_moves, int depth)
{
    assert(depth > 0);
    assert(best_moves.size() == 0);
    
    // 给全部棋子生成1步走法
    std::vector<JumballMove> moves;
    
    // 第一步的走法生成时，允许滚动
    GenerateMoves(0, moves);
    //PrintMoves(moves);
    assert(moves.size() > 0);
    
    std::vector<JumballMove>::iterator begin = moves.begin();
    std::vector<JumballMove>::iterator end = moves.end();
    
    // 评估当前的状态，走子之后，不应该比此局面差
    const short* identifiers = NULL;
    if (mini_)
    {
        identifiers = kJBEMiniPieceIdTables[corner_];
    }
    else
    {
        identifiers = kJBEPieceIdTables[corner_];
    }
    
    short piece_indexes[kJBEPieceCount];
    for (int i = 0; i < kJBEPieceCount; ++i)
    {
        std::map<short, short>::iterator iter = piece_map_id_index_.find(identifiers[i]);
        
        assert(iter != piece_map_id_index_.end());
        
        piece_indexes[i] = iter->second;
    }
    
    int sum_square_distance = JBESumSquareDistance(JBEDiagonalCorner(corner_) ,piece_indexes, kJBEPieceCount, mini_);
    
    while (begin != end) 
    {
        JumballMove move = *begin;
        
        DoMove(move);
        int score = Evaluate(JBEGetTo(move), depth - 1);
        
        if (score == sum_square_distance) 
        {
            // 同为最好的局面出现
            best_moves.push_back(move);
        } 
        else if (score < sum_square_distance)
        {
            // 更好的局面出现了，清空原来的结果
            best_moves.resize(0);
            best_moves.push_back(move);
            sum_square_distance = score;
        }
        
        UndoMove(move);
        ++begin;
    }
}

int JumballRobot::Evaluate(short last_moved, int depth)
{
    const short* identifiers = NULL;
    if (mini_)
    {
        identifiers = kJBEMiniPieceIdTables[corner_];
    }
    else
    {
        identifiers = kJBEPieceIdTables[corner_];
    }

    short piece_indexes[kJBEPieceCount];
    for (int i = 0; i < kJBEPieceCount; ++i)
    {
        std::map<short, short>::iterator iter = piece_map_id_index_.find(identifiers[i]);
        
        assert(iter != piece_map_id_index_.end());
        
        piece_indexes[i] = iter->second;
    }
    
    int sum_square_distance = JBESumSquareDistance(JBEDiagonalCorner(corner_) ,piece_indexes, kJBEPieceCount, mini_);
    
    // 如果是全部棋子都到达终点，为了区分一步到达与两步到达的优劣，在返回值上与深度关联
    if (sum_square_distance == JBEMinSumSquareDistance(mini_))
    {
        return sum_square_distance - depth;
    } 
    
    if (depth == 0) {
        return sum_square_distance;
    }
    
    std::vector<JumballMove> moves;
    GenerateMoves(last_moved, moves);
    //PrintMoves(moves);
    
    std::vector<JumballMove>::iterator begin = moves.begin();
    std::vector<JumballMove>::iterator end = moves.end();
    
    while (begin != end)
    {
        JumballMove move = *begin;
        DoMove(move);
        
        // 将深度与评分关联 
        int  score = Evaluate(JBEGetTo(move), depth - 1);
        
        if (score <= sum_square_distance)
        {
            // 更好的局面(距离之和最小)出现了
            sum_square_distance = score;
        }
        
        UndoMove(move);
        ++begin;
    }
    
    return sum_square_distance;
}

void JumballRobot::DoMove(JumballMove move)
{
    short from_index = JBEGetFrom(move);
    short to_index = JBEGetTo(move);
    board_[to_index] = board_[from_index];
    board_[from_index] = 0;
    
    std::map<short, short>::iterator iter = piece_map_index_id_.find(from_index);
    
    if (iter == piece_map_index_id_.end()) {
        printf("not found %d!", from_index);
    }
    
    assert(iter != piece_map_index_id_.end());
    
    short piece_id = iter->second;
    piece_map_index_id_.erase(from_index);
    piece_map_index_id_.insert(std::make_pair(to_index, piece_id));
    piece_map_id_index_.erase(piece_id);
    piece_map_id_index_.insert(std::make_pair(piece_id, to_index));
}

void JumballRobot::UndoMove(JumballMove move)
{
    short from_index = JBEGetFrom(move);
    short to_index = JBEGetTo(move);
    board_[from_index] = board_[to_index];
    board_[to_index] = 0;
    
    std::map<short, short>::iterator iter = piece_map_index_id_.find(to_index);
    
    assert(iter != piece_map_index_id_.end());
    
    short piece_id = iter->second;
    piece_map_index_id_.erase(to_index);
    piece_map_index_id_.insert(std::make_pair(from_index, piece_id));
    piece_map_id_index_.erase(piece_id);
    piece_map_id_index_.insert(std::make_pair(piece_id, from_index));
}

