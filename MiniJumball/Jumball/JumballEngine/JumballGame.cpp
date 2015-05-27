//
//  MiniJumballGame.cpp
//  MiniJumball
//
//  Created by Li Xu on 9/24/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#include "JumballGame.h"
#include "JumballEngine.h"
#include <iostream>
#include <assert.h>

JumballGame::JumballGame(bool player_1, bool player_2, bool player_3, bool player_4, bool player_5, bool player_6, JumballCorner first_corner, JumballRule rule):rule_(rule)
{
    assert(rule & kJBEScroll && rule & kJBEShortJump);
    
    memset(players_, 0, sizeof(players_));
    memset(board_, 0, sizeof(JumballBoard));
    mini_ = false;
    current_corner_ = first_corner;
    
    bool players[kJBECornerMax];
    players[0] = player_1;
    players[1] = player_2;
    players[2] = player_3;
    players[3] = player_4;
    players[4] = player_5;
    players[5] = player_6;
    
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        if (players[i]) {
            JBEInitCorner(board_, (JumballCorner)i, mini_);
            players_[i] = new JumballPlayer((JumballCorner)i, &board_, rule_, mini_);
        }
    }
}

JumballGame::JumballGame(bool player_1, bool player_2, bool player_3, JumballCorner first_corner, JumballRule rule)
:rule_(rule)
{
    assert(rule & kJBEScroll && rule & kJBEShortJump);
    
    memset(players_, 0, sizeof(players_));
    memset(board_, 0, sizeof(JumballBoard));
    mini_ = true;
    current_corner_ = first_corner;
    
    bool players[kJBECornerMax];
    players[0] = player_1;
    players[1] = false;
    players[2] = player_2;
    players[3] = false;
    players[4] = player_3;
    players[5] = false;
    
    for (int i = 0; i < kJBECornerMax; ++i)
    {
        if (players[i]) {
            JBEInitCorner(board_, (JumballCorner)i, mini_);
            players_[i] = new JumballPlayer((JumballCorner)i, &board_, rule_, mini_);
        }
    }
}

JumballGame::~JumballGame()
{
    for (int i = 0; i < kJBECornerMax; ++i) {
        if (players_[i]) {
            delete players_[i];
        }
    }
}

bool JumballGame::IsGameOver()
{
    return reach_dest_players_.size() == PlayerCount();
}

int JumballGame::PlayerCount()
{
    int playercount = 0;
    for (int i = 0; i < kJBECornerMax; ++i) {
        if (players_[i]) {
            ++playercount;
        }
    }
    return playercount;
}

bool JumballGame::ChangePlayer()
{
    if (CurrentPlayer()->ReachDestCount() == kJBEPieceCount) {
        
        // 避免重复添加
        if (std::find(reach_dest_players_.begin(), reach_dest_players_.end(), CurrentPlayer()) == 
            reach_dest_players_.end()
            )
        {
            reach_dest_players_.push_back(CurrentPlayer());
        }
        
    }
    
    for (int i = 0; i < kJBECornerMax; ++i) {
        int next = current_corner_ + i + 1;
        next %= kJBECornerMax;
        JumballPlayer* player = players_[next];
        if (player) {
            if (player->ReachDestCount() < kJBEPieceCount) {
                current_corner_ = (JumballCorner)next;
                return true;
            }
        }
    }
    return false;
}

JumballPlayer*  JumballGame::CurrentPlayer()
{
    return players_[current_corner_];
}

JumballPlayer*  JumballGame::NextPlayer()
{
    for (int i = 0; i < kJBECornerMax; ++i) {
        int index = (i + current_corner_ + 1) % kJBECornerMax;
        if (players_[index]) {
            return players_[index];
        }
    }
    return NULL;
}

JumballPlayer*  JumballGame::PlayerOfCorner(JumballCorner corner)
{
    return players_[corner];
}

JumballPlayer*  JumballGame::ReachDestPlayer(int index)
{
    assert(index < reach_dest_players_.size());
    return reach_dest_players_[index];
}