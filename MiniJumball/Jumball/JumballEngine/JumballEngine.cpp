//
//  JumballEngine.cpp
//  Jumball
//
//  Created by Li Xu on 10/6/12.
//  Copyright (c) 2012 Li Xu. All rights reserved.
//

#include "JumballEngine.h"
#include "JumballData.h"
#include "ModifiedSquareDistance.h"
#include <assert.h>
#include <vector>

const short* kJBEModifiedSquareDistanceTables[kJBECornerMax] = {kJBEModifiedSquareDistanceToSouth, kJBEModifiedSquareDistanceToSouthEast, kJBEModifiedSquareDistanceToNorthEast, kJBEModifiedSquareDistanceToNorth, kJBEModifiedSquareDistanceToNorthWest, kJBEModifiedSquareDistanceToSouthWest};

const short* kJBEMiniModifiedSquareDistanceTables[kJBECornerMax] = {kJBEMiniModifiedSquareDistanceToSouth, kJBEMiniModifiedSquareDistanceToSouthEast, kJBEMiniModifiedSquareDistanceToNorthEast, kJBEMiniModifiedSquareDistanceToNorth, kJBEMiniModifiedSquareDistanceToNorthWest, kJBEMiniModifiedSquareDistanceToSouthWest};

const short* kJBESquareDistanceTables[kJBECornerMax] = {kJBESquareDistanceToSouth, kJBESquareDistanceToSouthEast, kJBESquareDistanceToNorthEast, kJBESquareDistanceToNorth, kJBESquareDistanceToNorthWest, kJBESquareDistanceToSouthWest};

const short* kJBEMiniSquareDistanceTables[kJBECornerMax] = {kJBEMiniSquareDistanceToSouth, kJBEMiniSquareDistanceToSouthEast, kJBEMiniSquareDistanceToNorthEast, kJBEMiniSquareDistanceToNorth, kJBEMiniSquareDistanceToNorthWest, kJBEMiniSquareDistanceToSouthWest};

// 名称不能随意改动，即使是要改大小写或者加空格，请用户在用户代码中重新定义并设计变量
const char* kJBECornerName[kJBECornerMax] = {"South", "SouthEast", "NorthEast", "North", "NorthWest", "SouthWest"};

const int kJBEPieceCount = 10;
const int kJBEUnitStep[kJBEDirectionMax] = {2, -31, -33, -2, 31, 33};

const char kJBECornerCharacter[kJBECornerMax] = {'A', 'B', 'C', 'D', 'E', 'F'};
const short kJBEHomeCornerIndex[kJBECornerMax] = {783, 667, 411, 271, 387, 643};
const short kJBEMiniHomeCornerIndex[kJBECornerMax] = {719, 632, 440, 335, 422, 614};

const short kJBESouthPieceId[kJBEPieceCount] = {783, 750, 752, 717, 719, 721, 684, 686, 688, 690};
const short kJBESouthEastPieceId[kJBEPieceCount] = {667, 665, 634, 663, 632, 601, 661, 630, 599, 568};
const short kJBENorthEastPieceId[kJBEPieceCount] = {411, 442, 409, 473, 440, 407, 504, 471, 438, 405};
const short kJBENorthPieceId[kJBEPieceCount] = {271, 302, 304, 333, 335, 337, 364, 366, 368, 370};
const short kJBENorthWestPieceId[kJBEPieceCount] = {387, 389, 420, 391, 422, 453, 393, 424, 455, 486};
const short kJBESouthWestPieceId[kJBEPieceCount] = {643, 612, 645, 581, 614, 647, 550, 583, 616, 649};
const short* kJBEPieceIdTables[kJBECornerMax] = {kJBESouthPieceId, kJBESouthEastPieceId, kJBENorthEastPieceId, kJBENorthPieceId, kJBENorthWestPieceId, kJBESouthWestPieceId};

const short kJBEMiniSouthPieceId[kJBEPieceCount] = {719, 686, 688, 653, 655, 657, 620, 622, 624, 626};
const short kJBEMiniSouthEastPieceId[kJBEPieceCount] = {632, 630, 599, 628, 597, 566, 626, 595, 564, 533};
const short kJBEMiniNorthEastPieceId[kJBEPieceCount] = {440, 471, 438, 502, 469, 436, 533, 500, 467, 434};
const short kJBEMiniNorthPieceId[kJBEPieceCount] = {335, 368, 366, 401, 399, 397, 434, 432, 430, 428};
const short kJBEMiniNorthWestPieceId[kJBEPieceCount] = {422, 455, 424, 488, 457, 426, 521, 490, 459, 428};
const short kJBEMiniSouthWestPieceId[kJBEPieceCount] = {614, 583, 616, 552, 585, 618, 521, 554, 587, 620};
const short* kJBEMiniPieceIdTables[kJBECornerMax] = {kJBEMiniSouthPieceId, kJBEMiniSouthEastPieceId, kJBEMiniNorthEastPieceId, kJBEMiniNorthPieceId, kJBEMiniNorthWestPieceId, kJBEMiniSouthWestPieceId};

void JBEInitCorner(JumballBoard board, JumballCorner corner, const bool mini)
{
    assert(board);
    assert(corner < kJBECornerMax);
    
    const char character = kJBECornerCharacter[corner];
    const short* indexes = NULL;
    if (!mini)
        indexes = kJBEPieceIdTables[corner];
    else
        indexes = kJBEMiniPieceIdTables[corner];
    
    for (int i = 0; i < kJBEPieceCount; ++i)
    {
        board[indexes[i]] = character;
    }
}

bool JBEIndexToRowColumn(short index, int* row, int* column)
{
    assert(row);
    assert(column);
    
    // 不管是大棋盘还是小棋盘，中央位置的索引都是 527
    const short center = 527;
    const short row_base = center / 32;
    const short column_base = center % 32;
    
    if (0 <= index && 1024 > index)
    {
        //*row = row_base - index/32;
        //*column = index%32 - column_base;
        *row = row_base - (index >> 5);
        *column = (index & 31) - column_base;
        return true;
    }
    return false;
}

short JBERowColumnToIndex(int row, int column)
{
    static const short center = 527;
    
    if (-15 <= row && 16 >= row && -15 <= column && 16 >= column)
    {
        short offset = ((- row) << 5) + column;
        return offset + center;
    }
    return -1;
}

JumballDirection JBEDirectionByRowColumn(int from_row, int from_column, int to_row, int to_column)
{
    
    JumballDirection direction = kJBEDirectionMax;
    
    // 求斜率
    if (from_row != to_row)
    {
        int delta_column = to_column - from_column;
        int delta_row = to_row - from_row;
        if (delta_column == delta_row)
        {
            // 东北 西南方向
            if (to_row > from_row)
            {
                direction = kJBEDirectionNorthEast;
            }
            else
            {
                direction = kJBEDirectionSouthWest;
            }
        } else if (delta_column == -delta_row)
        {
            // 西北 东南方向
            if (to_row > from_row)
            {
                direction = kJBEDirectionNorthWest;
            }
            else
            {
                direction = kJBEDirectionSouthEast;
            }
        }
    }
    else
    {
        // 在同一水平位置
        if (to_column > from_column) {
            
            direction = kJBEDirectionEast;
        } else if (to_column < from_column)
        {
            direction = kJBEDirectionWest;
        }
    }

    return direction;
}

bool JBEOneStepBetween(const JumballBoard board, short from, short to, JumballRule rule, const bool mini)
{
    assert(0 <= from && 1024 > from);
    assert(0 <= to && 1024 > to);
    
    // to处有棋子
    if (board[to])
        return false;
    
    const char* bool_board;
    
    if (!mini)
        bool_board = kJBEBoolBoard;
    else
        bool_board = kJBEMiniBoolBoard;
    
    // 规则检查
    short delta = to - from;
    for (int i = 0; i < kJBEDirectionMax; ++i)
    {
        int unit_step = kJBEUnitStep[i];
        int two_unit_step = unit_step + unit_step;
        
        if (rule & kJBEScroll && delta == unit_step)
        {
            if (bool_board[to])
                return true;
        }
        else if (rule & kJBEShortJump && delta == two_unit_step)
        {
            short bridge = from + unit_step;
            if (board[bridge] && bool_board[bridge] && bool_board[to])
            {
                return true;
            }
        }
        else if (rule & kJBELongJump && delta == two_unit_step + two_unit_step)
        {
            short bridge = from + two_unit_step;
            if (board[bridge] &&
                !board[bridge - unit_step] &&
                !board[bridge + unit_step] &&
                bool_board[bridge] &&
                bool_board[to])
            {
                return true;
            }
        }
        else if (rule & kJBELongLongJump && delta == ((two_unit_step + unit_step) << 1 )/* 6 unit_step */)
        {
            short bridge = from + two_unit_step + unit_step;
            if (board[bridge] &&
                !board[bridge - unit_step] &&
                !board[bridge + unit_step] &&
                !board[bridge - two_unit_step] &&
                !board[bridge + two_unit_step] &&
                bool_board[bridge] &&
                bool_board[to]
                )
            {
                return true;
            }
        }
    }
    
    return false;
}

int JBEMinSumSquareDistance(bool mini)
{
    static int sum = 0;
    static int sum_mini = 0;
    
    if (sum == 0 && !mini)
    {
        // 南到南
        const short* indexes = kJBEPieceIdTables[kJBECornerSouth];
        for (int i = 0; i < kJBEPieceCount; ++i)
        {
            short index = indexes[i];
            //sum += kJBESquareDistanceToSouth[index];
            sum += kJBEModifiedSquareDistanceToSouth[index];
        }
    }
    
    if (sum_mini == 0 && mini)
    {
        // 南到南
        const short* indexes = kJBEMiniPieceIdTables[kJBECornerSouth];
        for (int i = 0; i < kJBEPieceCount; ++i)
        {
            short index = indexes[i];
            //sum_mini += kJBEMiniSquareDistanceToSouth[index];
            sum_mini += kJBEMiniModifiedSquareDistanceToSouth[index];
        }
    }
    
    if (mini)
        return sum_mini;
    else
        return sum;
}

int JBEMaxSumSquareDistance(bool mini)
{
    static int sum = 0;
    static int sum_mini = 0;
    
    if (sum == 0 && !mini)
    {
        // 南到北
        const short* indexes = kJBEPieceIdTables[kJBECornerSouth];
        for (int i = 0; i < kJBEPieceCount; ++i) {
            short index = indexes[i];
            //sum += kJBESquareDistanceToNorth[index];
            sum += kJBEModifiedSquareDistanceToNorth[index];
        }
    }
    
    if (sum_mini == 0 && mini)
    {
        // 南到北
        const short* indexes = kJBEMiniPieceIdTables[kJBECornerSouth];
        for (int i = 0; i < kJBEPieceCount; ++i) {
            short index = indexes[i];
            //sum += kJBEMiniSquareDistanceToNorth[index];
            sum += kJBEMiniModifiedSquareDistanceToNorth[index];
        }
    }
    
    if (mini)
        return sum_mini;
    else
        return sum;
}

int JBESumSquareDistance(JumballCorner to_coner, short *indexes, int piece_count, bool mini)
{
    int sum = 0;
    const short* square_distances = NULL;
    if (mini)
        //square_distances = kJBEMiniSquareDistanceTables[to_coner];
        square_distances = kJBEMiniModifiedSquareDistanceTables[to_coner];
    else
        //square_distances = kJBESquareDistanceTables[to_coner];
        square_distances = kJBEModifiedSquareDistanceTables[to_coner];
    
    for (int i = 0; i < piece_count; ++i)
    {
        sum += square_distances[indexes[i]];
    }
    
    return sum;
}

