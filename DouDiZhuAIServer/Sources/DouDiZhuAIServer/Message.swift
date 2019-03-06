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
    public let cards: [Card]
    public let error: String?
    
    private convenience init(_ type: MessageType) {
        self.init(type, playerID: nil, players: [], cards: [], error: nil)
    }
    
    private convenience init(_ type: MessageType, playerID: String, cards: [Card]) {
        self.init(type, playerID: playerID, players: [], cards: cards, error: nil)
    }
    
    private convenience init(_ type: MessageType, playerID: String) {
        self.init(type, playerID: playerID, players: [], cards: [], error: nil)
    }
    
    private convenience init(_ type: MessageType, playerID: String?, players: [String]) {
        self.init(type, playerID: playerID, players: players, cards: [], error: nil)
    }
    
    private init(_ type: MessageType, playerID: String?, players: [String], cards: [Card], error: String?) {
        self.type = type
        self.playerID = playerID
        self.error = error
        self.existingPlayers = players
        self.cards = cards
    }
    
    public static func joinGameSucceeded(player: Player, players: [String]) -> Message {
        return Message(.joinGameSucceded, playerID: player.id, players: players)
    }
    
    public static func joinGameFailed() -> Message {
        return Message(.joinGameFailed)
    }
    
    public static func addAIPlayerFailed() -> Message {
        return Message(.addAIPlayerFailed)
    }

    public static func playerTurn(player: Player) -> Message {
        return Message(.playerTurn, playerID: player.id)
    }

    public static func gameEnd(player: Player) -> Message {
        return Message(.gameEnd, playerID: player.id)
    }
    
    public static func newUserJoined(player: Player) -> Message {
        return Message(.newUserJoined, playerID: player.id)
    }
    
    public static func startGameFailed() -> Message {
        return Message(.startGameFailed)
    }
    
    public static func startGame(player: Player, cards: [Card]) -> Message {
        return Message(.gameStarted, playerID: player.id, cards: cards)
    }
}
