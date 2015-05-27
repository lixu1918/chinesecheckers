//
//  MiniJumballGame.h
//  MiniJumball
//
//  Created by Li Xu on 9/24/12.
//  Copyright (c) 2012 lifox416@126.com. All rights reserved.
//

#ifndef MiniJumball_MiniJumballGame_h
#define MiniJumball_MiniJumballGame_h

#include "JumballEngine.h"
#include "JumballPlayer.h"
#include <vector>


class JumballGame
{    
public:
    JumballGame(bool player_1, bool player_2, bool player_3, JumballCorner first_corner, JumballRule rule);
    JumballGame(bool player_1, bool player_2, bool player_3, bool player_4, bool player_5, bool player_6, JumballCorner first_corner, JumballRule rule);
    virtual ~JumballGame();
    
public:
    bool IsGameOver();
    int PlayerCount();
    // 在这里检查上一个玩家是否完成游戏
    bool ChangePlayer();
    JumballPlayer*  CurrentPlayer();
    JumballPlayer*  NextPlayer();
    JumballPlayer*  PlayerOfCorner(JumballCorner corner);
    JumballPlayer*  ReachDestPlayer(int index);
    
private:
    std::vector<JumballPlayer*> reach_dest_players_;
    JumballPlayer* players_[kJBECornerMax];
    JumballCorner current_corner_;
    JumballBoard board_;
    JumballRule rule_;
    bool mini_;
};

#endif
