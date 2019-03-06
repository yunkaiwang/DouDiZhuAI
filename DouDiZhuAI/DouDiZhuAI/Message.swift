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
    
    public static func joinGame() -> Message {
        return Message(type: .joinGame)
    }
    
    public static func addAIPlayer() -> Message {
        return Message(type: .addAIPlayer)
    }
    
    public static func startGame() -> Message {
        return Message(type: .startGame)
    }
}
