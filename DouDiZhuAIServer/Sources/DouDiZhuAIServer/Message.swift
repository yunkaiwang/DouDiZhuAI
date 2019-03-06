//
//  Message.swift
//
//  Created by yunkai wang on 2019-03-04.
//

import Foundation

public class Message: Codable {
    public let type: MessageType
    public let playerID: String?
    public let existingPlayers: [String]
    public let error: String?
    
    private convenience init(type: MessageType) {
        self.init(type: type, playerID: nil, players: [], error: nil)
    }
    
    private convenience init(type: MessageType, playerID: String?) {
        self.init(type: type, playerID: playerID, players: [], error: nil)
    }
    
    private convenience init(type: MessageType, playerID: String?, players: [String]) {
        self.init(type: type, playerID: playerID, players: players, error: nil)
    }
    
    private init(type: MessageType, playerID: String?, players: [String], error: String?) {
        self.type = type
        self.playerID = playerID
        self.error = error
        self.existingPlayers = players
    }
    
    public static func joinGameSucceeded(player: Player, players: [String]) -> Message {
        return Message(type: .joinGameSucceded, playerID: player.id, players: players)
    }
    
    public static func joinGameFailed() -> Message {
        return Message(type: .joinGameFailed, playerID: nil)
    }
    
    public static func addAIPlayerFailed() -> Message {
        return Message(type: .addAIPlayerFailed, playerID: nil)
    }

    public static func playerTurn(player: Player) -> Message {
        return Message(type: .playerTurn, playerID: player.id)
    }

    public static func gameEnd(player: Player) -> Message {
        return Message(type: .gameEnd, playerID: player.id)
    }
    
    public static func newUserJoined(player: Player) -> Message {
        return Message(type: .newUserJoined, playerID: player.id)
    }
    
    public static func startGameFailed() -> Message {
        return Message(type: .startGameFailed)
    }
}
