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
    public let error: String?
    
    private convenience init(type: MessageType, playerID: String?) {
        self.init(type: type, playerID: playerID, error: nil)
    }
    
    private init(type: MessageType, playerID: String?, error: String?) {
        self.type = type
        self.playerID = playerID
        self.error = error
    }
    
    public static func joinGame() -> Message {
        return Message(type: .joinGame, playerID: nil)
    }
}
