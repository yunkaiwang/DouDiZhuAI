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
    
    case playerDecisionTurn = "playerDecisionTurn" // player make the decision of whether be landlord or not
    case playerWantToBeLandlord = "playerWantToBeLandlord" // player wants to be landlord
    case playerWantToBeFarmer = "playerWantToBeFarmer" // player wants to be farmer
    
    case playerPillageTurn = "playerPillageTurn" // player make the decision of whether pillage the landlord or not
    case playerWantToPillageLandlord = "playerWantToPillageLandlord"
    case playerWillNotPillageLandlord = "playerWillNotPillageLandlord"
    
    case informLandlord = "informLandlord" // inform the players about the landlord of the game
    
    case makePlay = "makePlay" // player makes a play
    case playerTurn = "playerTurn" // notify the player it's their turn to play
    case gameEnd = "gameEnd" // game has ended (one player win)
}
