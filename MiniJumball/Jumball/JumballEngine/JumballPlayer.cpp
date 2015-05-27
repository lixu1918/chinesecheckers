//
//  MiniJumballPlayer.cpp
//  MiniJumball
//
//  Created by Li Xu on 9/24/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#include "JumballPlayer.h"
#include <iostream>
#include <assert.h>

// 构造函数

JumballPlayer::JumballPlayer(JumballCorner corner, JumballBoard* board, JumballRule rule, bool mini)
:corner_(corner), board_(board), rule_(rule), robot_(NULL), use_robot_(false), mini_(mini)
{
    const short* identifiers = NULL;
    if (mini_)
    {
        identifiers = kJBEMiniPieceIdTables[corner];
    } else
    {
        identifiers = kJBEPieceIdTables[corner];
    }
    // piece id是棋子在初始状态下，在内存棋盘中的索引。
    for (int i = 0; i < kJBEPieceCount; ++i)
    {
        short piece_id = identifiers[i];
        short piece_index = piece_id;
        piece_map_id_index_.insert(std::make_pair(piece_id, piece_index));
        piece_map_index_id_.insert(std::make_pair(piece_index, piece_id));
    }
}

JumballPlayer::~JumballPlayer()
{
    // 注意游戏结束的时候一定要先结束机器人思考线程，否则析构函数销毁机器人时会出问题
    if (robot_) {
        delete robot_;
    }
}

const char JumballPlayer::GetPieceCharacter()
{
    return kJBECornerCharacter[corner_];
}

int JumballPlayer::GetPieceIdByBoardIndex(int board_index)
{
    short piece_id = -1;
    std::map<short, short>::iterator r = piece_map_index_id_.find(board_index);
    if (r != piece_map_index_id_.end())
    {
        piece_id = r->second;
    }
    
    assert(piece_id != -1);
    
    return piece_id;
}

int JumballPlayer::GetPieceId(int index)
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
    return identifiers[index];
}

int JumballPlayer::ReachDestCount()
{
    const short* identifiers = NULL;
    if (mini_)
    {
        identifiers = kJBEMiniPieceIdTables[JBEDiagonalCorner(corner_)];
    }
    else
    {
        identifiers = kJBEPieceIdTables[JBEDiagonalCorner(corner_)];
    }
    
    const short* dest_indexes = identifiers;
    int reach_dest_count = 0;
    const char piece_character = GetPieceCharacter();
    for (int i = 0; i < kJBEPieceCount; ++i) {
        if ((*board_)[dest_indexes[i]] == piece_character)
        {
            ++reach_dest_count;
        }
    }
    return reach_dest_count;
}

void JumballPlayer::GetPieceViewBoardCoordinate(int piece, int* row, int* column)
{
    const short* identifiers = NULL;
    if (mini_)
    {
        identifiers = kJBEMiniPieceIdTables[JBEDiagonalCorner(corner_)];
    }
    else
    {
        identifiers = kJBEPieceIdTables[JBEDiagonalCorner(corner_)];
    }
    const short piece_id = identifiers[piece];
    
    std::map<short, short>::iterator iter = piece_map_id_index_.find(piece_id);
    
    assert(iter != piece_map_id_index_.end());

    JBEIndexToRowColumn(iter->second, row, column);
}

void JumballPlayer::GetPieceViewBoardHomeCoordinate(int piece, int* row, int* column)
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
    const short* indexes = identifiers;
    const short index = indexes[piece];
    JBEIndexToRowColumn(index, row, column);
}

bool JumballPlayer::AddFootPrint(int row, int column)
{
    const short to_index = JBERowColumnToIndex(row, column);
    
    if (to_index >= 0) {
        
        // 设置第一个脚印（或换选棋子）
        if ((*board_)[to_index] == GetPieceCharacter())
        {
            std::map<short, short>::iterator iter = piece_map_index_id_.find(to_index);
    
            if (iter != piece_map_index_id_.end()) 
            {
                footprints_.resize(1);
                footprints_[0] = to_index;
                return true;
            }
        }
        
        if (footprints_.size() > 0)
        {
            // 从起点开始，遍历每一个历史脚印
            // 当从某历史脚印能够到达 to index 时，则将该历史脚印之后的脚印删除
            // 并将 to index 添加到脚印
            for (int i = 0; i < footprints_.size(); ++i) 
            { 
                short foot_print = footprints_[i];
                JumballRule strict_rule = rule_;
                if (i > 0) 
                {
                    // 从 i = 1 开始就只能跳了
                    strict_rule &= ~kJBEScroll;
                    
                    // 如果从 0 到 1 是滚而不是跳，则可以 break 返回 false 了
                    if (!JBEOneStepBetween(*board_, footprints_[0], footprints_[1], strict_rule, mini_)) {
                        break;
                    }
                }
                
                if (JBEOneStepBetween(*board_, foot_print, to_index, strict_rule, mini_))
                {
                    // 将该历史脚印之后的脚印删除
                    footprints_.resize(i + 1);
                    footprints_.push_back(to_index);
                    return true;
                }
            }
        }
    }
    return false;
}

int JumballPlayer::FootPrintCount()
{
    return footprints_.size();
}

short JumballPlayer::GetFootPrint(int index)
{
    assert(index < footprints_.size());
    return footprints_[index];
}

bool JumballPlayer::GetFootPrint(int index, int* row, int* column)
{
    if (index >= 0 && index < footprints_.size()) {
        
        const short footprint = footprints_[index];
        return JBEIndexToRowColumn(footprint, row, column);
    }
    return false;
}

bool JumballPlayer::MoveFootPrintPieceTo(int row, int column)
{
    const short to_index = JBERowColumnToIndex(row, column);
    if (footprints_.size() > 0 && to_index >= 0) {
        
        for (int i = 0; i < footprints_.size(); ++i) 
        { 
            short foot_print = footprints_[i];
            JumballMove strict_rule = rule_;
            if (i > 0) 
            {
                // 从 i = 1 开始就只能跳了
                strict_rule &= ~kJBEScroll;
            }
            
            if (JBEOneStepBetween(*board_, foot_print, to_index, strict_rule, mini_))
            {
                // 将该历史脚印之后的脚印删除
                footprints_.resize(i + 1);
                
                // 将目的地添加到脚印中
                footprints_.push_back(to_index);
                
                // 修改棋盘内存 返回
                short from_index = footprints_[0];
                std::map<short, short>::iterator iter = piece_map_index_id_.find(from_index);
                assert(iter != piece_map_index_id_.end());
                short move_piece_id = iter->second;
                
                piece_map_id_index_.erase(move_piece_id);
                piece_map_id_index_.insert(std::make_pair(move_piece_id, to_index));
                piece_map_index_id_.erase(from_index);
                piece_map_index_id_.insert(std::make_pair(to_index, move_piece_id));
                (*board_)[to_index] = (*board_)[from_index];
                (*board_)[from_index] = '\0';
                return true;
            }
        }
    }
    return false;
}

void JumballPlayer::ClearFootPrints()
{
    footprints_.resize(0);
}

void JumballPlayer::UseRobot(bool use)
{
    use_robot_ = use;
}

bool JumballPlayer::IsUsingRobot()
{
    return use_robot_;
}

void JumballPlayer::PrintMoves(std::vector<JumballMove> &moves)
{
    std::vector<JumballMove>::iterator begin = moves.begin();
    std::vector<JumballMove>::iterator end = moves.end();
    printf("%lu moves\n", moves.size());
    
    while (begin != end) 
    {
        short from = JBEGetFrom(*begin);
        short to = JBEGetTo(*begin);
        printf("%d -> %d\n", from, to);
        ++begin;
    }
}

void JumballPlayer::GenerateMoves(short exclude, std::vector<JumballMove> &moves)
{
    assert(moves.size() == 0);
    
    for (int i = 0; i < kJBEPieceCount; ++i) {
        
        const short piece_id = GetPieceId(i);
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

void JumballPlayer::PrintIdIndexAndIndexIdMap()
{
    printf("%lu id-index pair       %lu index-id pair\n", piece_map_id_index_.size(), piece_map_index_id_.size());
    std::map<short, short>::iterator id_index_begin = piece_map_id_index_.begin();
    std::map<short, short>::iterator id_index_end = piece_map_id_index_.end();
    
    std::map<short, short>::iterator index_id_begin = piece_map_index_id_.begin();
    std::map<short, short>::iterator index_id_end = piece_map_index_id_.end();
    
    int index = 0;
    while (id_index_begin != id_index_end && index_id_begin != index_id_end) {
        
        printf("%d (%d-%d)          (%d %d)\n", index, id_index_begin->first, id_index_begin->second, index_id_begin->first, index_id_begin->second);
        
        ++index;
        ++id_index_begin;
        ++index_id_begin;
    }
}

void JumballPlayer::AddPieceMove(short orignal, short from, std::vector<JumballMove> &moves)
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
            
            if (!(*board_)[to] && (*bool_board)[to]) {
                
                JumballMove move = JBEMakeMove(orignal, to);
                
                if (std::find(moves.begin(), moves.end(), move) == moves.end())
                {
                    // 该位置不曾搜索过
                    moves.push_back(move);
                    //AddPieceMove(orignal, to, moves);
                }
            }
        }
        
        // short jump
        if (rule_ & kJBEShortJump)
        {
            short to = from + two_unit_step;
            short bridge = from + unit_step;
            if (bridge >= 0 && bridge < sizeof(JumballBoard) &&
                to >= 0 && to < sizeof(JumballBoard) &&
                !(*board_)[to] && (*board_)[bridge] &&
                (*bool_board)[bridge] && 
                (*bool_board)[to]) 
            {
                JumballMove move = JBEMakeMove(orignal, to);
                if (std::find(moves.begin(), moves.end(), move) == moves.end()) 
                {
                    moves.push_back(move);
                    AddPieceMove(orignal, to, moves);  
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
                !(*board_)[bridge - unit_step] &&
                (*board_)[bridge] && 
                !(*board_)[bridge + unit_step] && 
                !(*board_)[to] &&
                (*bool_board)[bridge] && 
                (*bool_board)[to]) 
            {
                JumballMove move = JBEMakeMove(orignal, to);
                if (std::find(moves.begin(), moves.end(), move) == moves.end()) 
                {
                    moves.push_back(move);
                    AddPieceMove(orignal, to, moves);  
                } 
            }
        }
        
        // long long jump
        if (rule_ & kJBELongLongJump)
        {
            short bridge = from + two_unit_step + unit_step;
            short to = bridge + two_unit_step + unit_step;
            if (bridge >= 0 && bridge < sizeof(JumballBoard) &&
                to >= 0 && to < sizeof(JumballBoard) &&
                !(*board_)[bridge - two_unit_step] && !(*board_)[bridge - unit_step] &&
                (*board_)[bridge] && 
                !(*board_)[bridge + unit_step] && !(*board_)[bridge + two_unit_step] &&
                !(*board_)[to] && 
                (*bool_board)[bridge] && (*bool_board)[to])
            {
                JumballMove move = JBEMakeMove(orignal, to);
                if (std::find(moves.begin(), moves.end(), move) == moves.end()) 
                {
                    moves.push_back(move);
                    AddPieceMove(orignal, to, moves);  
                } 
            }
        }
    }
}

// 一个递归调用
// 原本打算使用效率更高的 从from和to一起，从两头到中间的广度优先搜索。
// 还是先采取更简单的，从from到to的深度优先搜索吧 最大深度设置为20
void JumballPlayer::FullFillFootPrints(short original, short from, short to, int depth, std::vector<short> &history_from)
{
    const static int max_depth = 25;
    static bool hit = false;
    if (depth == 0) {
        hit = false;
    }
    
    if (std::find(history_from.begin(), history_from.end(), from) != history_from.end()) {
        return;
    }
        
    footprints_.push_back(from);
    history_from.push_back(from);
    
    JumballRule rule = rule_;
    
    // 如果不是第一次调用，那么就不能滚了
    if (depth != 0) {
        rule = rule_ & ~kJBEScroll;
    }
    
    if (JBEOneStepBetween(*board_, from, to, rule, mini_))
    {
        hit = true;
        footprints_.push_back(to);
    } 
    
    if (depth < max_depth && !hit)
    {
        const char* bool_board = NULL;
        if (mini_) {
            bool_board = kJBEMiniBoolBoard;
        } else {
            bool_board = kJBEBoolBoard;
        }
        
        // 规则检查
        //short delta = to - from;
        for (int i = 0; i < kJBEDirectionMax; ++i) {
            
            int unit_step = kJBEUnitStep[i];
            int two_unit_step = unit_step + unit_step;
            
            if (rule & kJBEShortJump)
            {
                short bridge = from + unit_step;
                short new_from = bridge + unit_step;
                if ((*board_)[bridge] && 
                    !(*board_)[new_from] &&
                    bool_board[bridge] &&
                    bool_board[new_from] &&
                    bridge != original) 
                {
                    FullFillFootPrints(original, new_from, to, depth + 1, history_from);
                }
            } 
            
            if (hit) {
                break;
            }
            
            if (rule & kJBELongJump)
            {
                short bridge = from + two_unit_step;
                short new_from = bridge + two_unit_step;
                if ((*board_)[bridge] && 
                    bool_board[bridge] &&
                    bool_board[new_from] &&
                    !(*board_)[bridge - unit_step] && 
                    !(*board_)[bridge + unit_step] &&
                    !(*board_)[new_from] && bridge != original)
                {
                    FullFillFootPrints(original, new_from, to, depth + 1, history_from);
                }
            }
            
            if (hit) {
                break;
            }
            
            if (rule & kJBELongLongJump)
            {
                short bridge = from + two_unit_step + unit_step;
                short new_from = bridge + two_unit_step + unit_step;
                if ((*board_)[bridge] && 
                    bool_board[bridge] &&
                    bool_board[new_from] &&
                    !(*board_)[bridge - unit_step] && 
                    !(*board_)[bridge + unit_step] &&
                    !(*board_)[bridge - two_unit_step] && 
                    !(*board_)[bridge + two_unit_step] &&
                    !(*board_)[new_from] && bridge != original)
                {
                    FullFillFootPrints(original, new_from, to, depth + 1, history_from);
                }
            }
            
            if (hit) {
                break;
            }
        }
    }
    
    // 如果没有找到从from到to的路线，则需要把原来压入footprints_的弹出
    if (!hit) {
        footprints_.pop_back();
    }
}

void JumballPlayer::BeginThink()
{
    robot_is_thinking_ = true;
    
    if (robot_ == NULL) {
        robot_ = new JumballRobot(corner_, rule_, mini_);
    }
    
    robot_->ResetJumballBoard(*board_, piece_map_id_index_, piece_map_index_id_);
    
    std::vector<JumballMove> best_moves;
    robot_->SearchBestMoves(best_moves, 2);
    
    // TODO:best_moves.size() 为 0 的情况
    // 一般来说，都能得到大于或等于一个最佳走法
    // 为0一般是自己的目的地里有其他棋子被封堵死，这时候需要给其他棋子让路（放出来）
    
    int move_index = rand() % best_moves.size();
    JumballMove move = best_moves[move_index];    
    
    short from = JBEGetFrom(move);
    short to = JBEGetTo(move);
    
    int row, column;
    JBEIndexToRowColumn(from, &row, &column);
    JBEIndexToRowColumn(to, &row, &column);
    
    const char* bools = kJBEBoolBoard;
    if (mini_) {
        bools = kJBEMiniBoolBoard;
    }
    
    // TODO 生成从 from 到 to 的脚印
    footprints_.resize(0);
    std::vector<short> history_footprints;
    FullFillFootPrints(from, from, to, 0, history_footprints);

    robot_is_thinking_ = false;
}

bool JumballPlayer::IsThinkFinish()
{
    return !robot_is_thinking_;
}
