//
//  MessageType.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-03-04.
//  Copyright © 2019 yunkai wang. All rights reserved.
//

import Foundation

public enum MessageType: String, Codable {
    case joinGame = "joinGame" // new player will be joining the game
    case joinGameSucceded = "joinGameSucceded" // new player join the game successfully
    case joinGameFailed = "joinGameFailed" // new player failed to join the game
    
    case newUserJoined = "newUserJoined" // new player joined the game
    
    case addAIPlayer = "addAIPlayer" // add AI player
    case addAIPlayerFailed = "addAIPlayerFailed" // add AI player failed
    
    case startGame = "startGame" // start game
    case startGameFailed = "startGameFailed" // start game failed
    
    case gameStarted = "gameStarted" // game has been started
    
    case gameEnd = "gameEnd" // game has ended (one player win)
    case informDecision = "informDecision" // inform the client/server about the decision of whether be a landlord or not
    case notifyLandlord = "notifyLandord" // notify the landlord
    case makePlay = "makePlay" // player makes a play
    case playerTurn = "playerTurn" // notify the player it's their turn to play
}
