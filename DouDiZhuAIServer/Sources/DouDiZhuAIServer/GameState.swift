//
//  GameState.swift
//
//  Created by yunkai wang on 2019-03-06.
//

import Foundation

enum GameState {
    case created // the game is created but not started
    case started // the game is started
    case choosingLandlord // the game is now choosing the landlord
    case pillagingLandlord // the game is now pillaging the landlord
    case inProgress // the game is in progress (the landlord has been elected)
}
