//
//  GameState.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-03-04.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

enum GameState {
    case connected // connected with the back-end
    case disconnected // disconnected from the back-end
    case choosingLandlord // the game is now choosing the landlord
    case pillagingLandlord // the game is now pillaging the landlord
    case inProgress // the game is in progress (the landlord has been elected)
    case active // current player is playing
    case waiting // waiting for other players to play
}
