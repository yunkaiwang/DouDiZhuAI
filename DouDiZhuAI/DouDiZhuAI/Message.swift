//
//  Message.swift
//  DouDiZhuAI
//
//  Created by yunkai wang on 2019-03-04.
//  Copyright © 2019 yunkai wang. All rights reserved.
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
    
    public static func joinGame() -> Message {
        return Message(.joinGame)
    }
    
    public static func addAIPlayer() -> Message {
        return Message(.addAIPlayer)
    }
    
    public static func startGame() -> Message {
        return Message(.startGame)
    }
}
