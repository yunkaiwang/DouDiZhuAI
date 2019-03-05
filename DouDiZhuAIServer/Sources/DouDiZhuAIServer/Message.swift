//
//  Message.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

public class Message: Codable {
    public let type: MessageType
    public let playerID: String?
    public let error: String?
    
    private convenience init(type: MessageType, playerID: String?) {
        self.init(type: type, playerID: playerID, error: nil)
    }
    
    private init(type: MessageType, playerID: String?, error: String?) {
        self.type = type
        self.playerID = playerID
        self.error = error
    }
    
    public static func joinGameSucceeded(player: Player) -> Message {
        return Message(type: .joinGameSucceded, playerID: player.id)
    }
    
    public static func joinGameFailed() -> Message {
        return Message(type: .joinGameFailed, playerID: nil)
    }
    
    public static func addAIPlayerSucceded() -> Message {
        return Message(type: .addAIPlayerSucceded, playerID: nil)
    }
    
    public static func addAIPlayerFailed() -> Message {
        return Message(type: .addAIPlayerFailed, playerID: nil)
    }
    
//    public static func joinGame() -> Message {
//
//        return Message(type: .joinGame, playerID: player)
//    }

    public static func playerTurn(player: Player) -> Message {
        return Message(type: .playerTurn, playerID: player.id)
    }

    public static func gameEnd(player: Player) -> Message {
        return Message(type: .gameEnd, playerID: player.id)
    }
}
